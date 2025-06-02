<< eof tr -d ' ' | git credential-cache store
  protocol=https
  host=github.com
  username=nonce
  password=$GIT_TOKEN
eof