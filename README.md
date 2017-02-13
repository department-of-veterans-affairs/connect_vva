vva_connect
===

Example Usage
------------- 

```ruby
require 'vva'

v = VVA::DocumentListWebService.new(
  wsdl: "http://service.example.com?wsdl",
  ssl_cert_file: "/path/to/cert",
  ssl_cert_key_file: "/path/to/private/key",
  ssl_ca_cert: "/path/to/ca/file"
)
puts v.get_by_claim_number("777")
```

## Development

After checking out the repo, run `bundle install` to install dependencies. You can also run `bundle console` for an interactive prompt that will allow you to experiment. If you want to use `pry`, run `bundle config console pry` and then `bundle console`.

License
=======

[The project is in the public domain](LICENSE.md), and all contributions will also be released in the public domain. By submitting a pull request, you are agreeing to waive all rights to your contribution under the terms of the [CC0 Public Domain Dedication](http://creativecommons.org/publicdomain/zero/1.0/).

This project constitutes an original work of the United States Government.
