vva_connect
===

Example Usage
-------------

```ruby
require 'vva'

v = VVA::DocumentListWebService.new(
  wsdl: 'http://service.example.com?wsdl',
  username: "xxx",
  password: "xxxxxx"
)
puts v.get_by_claim_number("777")
```

License
=======

[The project is in the public domain](LICENSE.md), and all contributions will also be released in the public domain. By submitting a pull request, you are agreeing to waive all rights to your contribution under the terms of the [CC0 Public Domain Dedication](http://creativecommons.org/publicdomain/zero/1.0/).

This project constitutes an original work of the United States Government.
