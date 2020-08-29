"""

# Converts Euro into another currency.

    convert(x::Number, currency::String)

## Arguments

    - `x` : a Number
    - `currency` : A currency out of ["CZK", "PLN", "MXN", "TRY", "ISK", "USD", "RUB", "GBP", "JPY", "THB", "CNY", "KRW", "SEK", "BRL", "BGN", "HUF", "SGD", "CHF", "IDR", "NZD", "MYR", "ZAR", "CAD", "PHP", "HKD", "AUD", "INR", "HRK", "NOK", "DKK", "RON", "ILS"]

## Examples

```jldoctest
julia> convert(100, "USD")
julia> convert(10, "CAD")
julia> convert(1, "ASD")
julia>
julia> x = rand(100)
julia> convert.(x, "CAD")
```
"""
function convert(x::Number, symbol::String = "")
  
  url = "https://api.exchangeratesapi.io/"
  url *= "latest/"
  response = HTTP.get(url, cookies = true)
  body = JSON.parse(String(response.body))
  
  if symbol ∉ keys(body["rates"])
      error("Currency '$symbol' is not yet supported")
  end
  
  x *= body["rates"][symbol]
  return x
end
