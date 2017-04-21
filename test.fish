set user_id (uuidgen)
set user_email 'test@user.com'
set user_password 'pass1234'
set user_password_hash '$2b$12$IneU/bZy3OtIAON6uUOZOu0l6vEvg51EXveoxK9QSQOhTiPvH5ZzC'

set client_id (uuidgen)
set client_name 'some_mis'
set client_secret 'some_secret'
set client_redirect_uri 'some_uri'

psql trump_api_dev -c "delete from apps"
psql trump_api_dev -c "delete from users"
psql trump_api_dev -c "delete from clients"

psql trump_api_dev -c "insert into users (id, email, password, inserted_at, updated_at) values ('$user_id', '$user_email', '$user_password_hash', now(), now())"
psql trump_api_dev -c "insert into clients (id, name, secret, redirect_uri, inserted_at, updated_at) values ('$client_id', '$client_name', '$client_secret', '$client_redirect_uri', now(), now())"

# 1. Login user

set login_result (curl -s -c /tmp/cookie.txt -X POST -H 'Content-Type: application/json' -d "{\"user\":{\"email\":\"$user_email\",\"password\":\"$user_password\"}}" 'http://localhost:4000/oauth/users/login')
echo $login_result | jq

# Session is now set on frontend.

# 2. Frontend shows user a "An application application requested an access on behalf of your account. Continue?". User clicks "Yes":

set code_result (curl -s -b /tmp/cookie.txt -X POST -H 'Content-Type: application/json' -d "{\"app\":{\"client_id\":\"$client_id\", \"scope\":\"read,write\", \"redirect_uri\":\"$client_redirect_uri\"}}" 'http://localhost:4000/oauth/apps/authorize')
echo $code_result | jq

# 3. Front-end redirects browser to redirect_uri, providing the following as GET params: state,

# 4. Client exchanges the code for access/secret token pair

set code (echo $code_result | jq -r '.token.value')

curl -s -X POST -H 'Content-Type: application/json' -H "Authentication: Bearer $code" -d "{\"token\":{}}" 'http://localhost:4000/oauth/tokens'
# set token_result ()
# echo $token_result | jq
