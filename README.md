# Twitter url parser
Or I don't have other idea how to name it

### Prerequisites
- Ruby 2.5

### Installation

- copy `.env.sample` to `.env` in project root
- run
  ```
    > bundle install
  ```


### Usage

Reads all tweets from users I follow
```
> ./tweets get
```

Reads all tweets since X date - MUST be in YYYY-MM-DD format
```
> ./tweets get --since YYYY-MM-DD
```

Reads all tweets until X date - MUST be in YYYY-MM-DD format
```
> ./tweets get --until YYYY-MM-DD
```

Reads all tweets between given date - MUST be in YYYY-MM-DD format
```
> ./tweets get --since YYYY-MM-DD --until YYYY-MM-DD
```


### Tests

```
rspec
```
