# 0. Preparation

set user_id (uuidgen)
set user_email 'test@user.com'
set user_password 'pass1234'
set user_password_hash '$2b$12$IneU/bZy3OtIAON6uUOZOu0l6vEvg51EXveoxK9QSQOhTiPvH5ZzC'

set client_id (uuidgen)
set client_name 'some_mis'
set client_secret 'some_secret'
set client_redirect_uri 'some_uri'

set client_type_id (uuidgen)
set client_type_name 'some_client_type'
set client_type_scope 'session:read:write'

set role_id (uuidgen)
set role_name 'some_user_role'
set role_scope 'some_service:read'

set user_role_id (uuidgen)
set client_client_type_id (uuidgen)

psql mithril_api_dev -c "delete from apps"
psql mithril_api_dev -c "delete from users"
psql mithril_api_dev -c "delete from clients"
psql mithril_api_dev -c "delete from tokens"

psql mithril_api_dev -c "delete from roles"
psql mithril_api_dev -c "delete from user_roles"
psql mithril_api_dev -c "delete from client_types"
psql mithril_api_dev -c "delete from client_client_types"

psql mithril_api_dev -c "insert into roles (id, name, scope, inserted_at, updated_at) values ('$role_id', '$role_type', '$role_scope', now(), now())"
psql mithril_api_dev -c "insert into client_types (id, name, scope, inserted_at, updated_at) values ('$client_type_id', '$client_type_name', '$client_type_scope', now(), now())"

psql mithril_api_dev -c "insert into users (id, email, password, inserted_at, updated_at) values ('$user_id', '$user_email', '$user_password_hash', now(), now())"
psql mithril_api_dev -c "insert into clients (id, name, secret, redirect_uri, inserted_at, updated_at) values ('$client_id', '$client_name', '$client_secret', '$client_redirect_uri', now(), now())"

psql mithril_api_dev -c "insert into user_roles (id, user_id, role_id, inserted_at, updated_at) values ('$user_role_id', '$user_id', '$role_id', now(), now())"
psql mithril_api_dev -c "insert into client_client_types (id, client_id, client_type_id, inserted_at, updated_at) values ('$client_client_type_id', '$client_id', '$client_type_id', now(), now())"

# 1. Login user

set login_result (
  set payload (
    jq --monochrome-output \
       --compact-output \
       --null-input \
       --arg client_id $client_id \
       --arg user_email $user_email \
       --arg user_password $user_password \
       '{
         "token": {
           "grant_type": "password",
           "email": $user_email,
           "password": $user_password,
           "client_id": $client_id,
           "scope": "app:authorize"
         }
       }'
  )

  curl --silent \
       --request POST \
       --header 'Content-Type: application/json' \
       --data $payload \
       'http://localhost:4000/oauth/tokens'
)

echo $login_result | jq

# Front-end is now able to issue an app authentication call.

# 2. Frontend shows user a "An application application requested an access on behalf of your account. Continue?". User clicks "Yes":
#    Client initially asked for api:read and api:write, so create it.

set code_result (
  set password_token (echo $login_result | jq -r '.data.value')

  set payload (
    jq --monochrome-output \
       --compact-output \
       --null-input \
       --arg client_id $client_id \
       --arg client_redirect_uri $client_redirect_uri \
       '{
         "app": {
           "client_id": $client_id,
           "redirect_uri": $client_redirect_uri,
           "scope": "some_api:read,some_api:write"
         }
       }'
  )

  curl --silent \
       --request POST \
       --header 'Content-Type: application/json' \
       --header "Authorization: Bearer $password_token" \
       --data $payload \
       'http://localhost:4000/oauth/apps/authorize'
)
echo $code_result | jq

# 3. Front-end redirects browser to redirect_uri, providing the following as GET params: state,

# 4. Client exchanges the code for access/secret token pair

set tokens_result (
  set payload (
    jq --monochrome-output \
       --compact-output \
       --null-input \
       --arg code (echo $code_result | jq -r '.data.value') \
       --arg client_id $client_id \
       --arg client_secret $client_secret \
       --arg client_redirect_uri $client_redirect_uri \
       '{
         "token": {
           "grant_type": "authorization_code",
           "client_id": $client_id,
           "client_secret": $client_secret,
           "code": $code,
           "redirect_uri": $client_redirect_uri
         }
       }'
  )

  curl --silent \
       --request POST \
       --header 'Content-Type: application/json' \
       --header "Authentication: Bearer $code" \
       --data $payload \
       'http://localhost:4000/oauth/tokens'
)

echo $tokens_result | jq
