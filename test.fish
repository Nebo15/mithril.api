set user_id (uuidgen)
set user_email 'test@user.com'
set user_password 'pass1234'
set user_password_hash '$2b$12$IneU/bZy3OtIAON6uUOZOu0l6vEvg51EXveoxK9QSQOhTiPvH5ZzC'

# pass1234

psql trump_api_dev -c "delete from users"
psql trump_api_dev -c "insert into users (id, email, password, inserted_at, updated_at) values ('$user_id', '$user_email', '$user_password_hash', now(), now())"

curl -v -X POST -H 'Content-Type: application/json' -d "{\"user\":{\"email\":\"$user_email\",\"password\":\"$user_password\"}}" 'http://localhost:4000/oauth/users/login'
