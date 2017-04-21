set user_id (uuidgen)
set user_email 'test@user.com'
set user_password '$2b$12$p/rUfIGNhgnahKkjOedn/OeYWbVADwWwKWxLgq4Aa2kRTOYniR7Y'.

# pass1234

psql trump_api_dev -c "delete from users"
psql trump_api_dev -c "insert into users (id, email, password, inserted_at, updated_at) values ('$user_id', '$user_email', '$user_password', now(), now())"

curl -X POST -H 'Content-Type: application/json' -d "{\"user\":{\"email\":\"$user_email\",\"password\":\"pass1234\"}}" 'http://localhost:4000/users/login'
