function logout --wraps='loginctl terminate-user $USER' --description 'alias logout loginctl terminate-user $USER'
    loginctl terminate-user $USER $argv
end
