"""

# Download Conversion Rates with the Foreign exchange rates API.

    get_symbols(symbol1::String, symbol2, start_at::String = "", end_at::String = "")

## Arguments

    - `symbol1` : A character specyfing the currency out of ["CZK", "PLN", "MXN", "TRY", "ISK", "USD", "RUB", "GBP", "JPY", "THB", "CNY", "KRW", "SEK", "BRL", "BGN", "HUF", "SGD", "CHF", "IDR", "NZD", "MYR", "ZAR", "CAD", "PHP", "HKD", "AUD", "INR", "HRK", "NOK", "DKK", "RON", "ILS"]
    - `symbol2` : A character or Vector specyfing the currency out of ["CZK", "PLN", "MXN", "TRY", "ISK", "USD", "RUB", "GBP", "JPY", "THB", "CNY", "KRW", "SEK", "BRL", "BGN", "HUF", "SGD", "CHF", "IDR", "NZD", "MYR", "ZAR", "CAD", "PHP", "HKD", "AUD", "INR", "HRK", "NOK", "DKK", "RON", "ILS"]
    - `start_at` : A character specyfing the date, e.g. "2012-01-01"
    - `end_at` : A character specyfing the date, e.g. "2012-01-01"
    - `currency` : A character specyfing the currency out of ["CZK", "PLN", "MXN", "TRY", "ISK", "USD", "RUB", "GBP", "JPY", "THB", "CNY", "KRW", "SEK", "BRL", "BGN", "HUF", "SGD", "CHF", "IDR", "NZD", "MYR", "ZAR", "CAD", "PHP", "HKD", "AUD", "INR", "HRK", "NOK", "DKK", "RON", "ILS"]

## Examples

```jldoctest
julia> using CurrencyAPI
julia>
julia> x1 = get_symbols("USD", "CAD", "2000-01-01", "2018-01-01")
julia> x2 = get_symbols("USD", ["EUR", "CHF", "CAD"], "2000-01-01", "2018-01-01")
julia>
julia> using Plots
julia>
julia> plot(x2)
```
"""
function get_symbols(symbol1::String, symbol2, start_at::String = "", end_at::String = "")

    symbol2 = ifelse(symbol2 isa String, [symbol2], symbol2)

    start_at = ifelse(start_at == "", Dates.format(Dates.today() - Year(1), "yyyy-mm-dd"), start_at)
    end_at = ifelse(end_at == "", Dates.format(Dates.today() - Day(1), "yyyy-mm-dd"), end_at)
    if (Dates.Date(start_at) >= Dates.today() - Day(1) ||
        Dates.Date(end_at) >= Dates.today() - Day(1))
        error("in get_symbols: start_at lies in the future")
    end
    Dates.Date(start_at) > Dates.Date(end_at) ? error("in get_symbols: start_at must be older than end_at") : nothing

    url = "https://api.exchangeratesapi.io/"
    url = url * "history?start_at=$start_at&end_at=$end_at&symbols="
    for symbol ∈ symbol2
        url = url * symbol * ","
    end
    url = ifelse(last(url) == ',', chop(url), url)
    url = url * "&base=$symbol1"

    response = HTTP.get(url, cookies = true)
    body = JSON.parse(String(response.body))

    f = [body["rates"][i] for i ∈ keys(body["rates"])]
    f2 = [[f[i][j] for j ∈ keys(f[i])] for i ∈ 1:length(f)]
    f3 = DataFrame([[f2[i][j] for i ∈ 1:length(f2)] for j ∈ 1:length(symbol2)])

    x = DataFrame(:Time => Date.([i for i ∈ keys(body["rates"])]))
    x = hcat(x, f3, makeunique = true)
    sort!(x)
    x = TimeArray(x, timestamp = :Time)
    TimeSeries.rename!(x, Symbol.([i for i ∈ keys(f[1])]))

    return(x)
end
