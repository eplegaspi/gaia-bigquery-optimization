## Prerequirement
- [Python 3.9](https://www.python.org/downloads/)
- [Git](https://git-scm.com/)

## Installation 
```bash
# create a python virtual environment
python -m venv dbt-env 

# activate python virtual environment (linux/MacOS)
source dbt-env/bin/activate 

# activate python virtual environment (Windows)
dbt-env\Scripts\activate.bat

# installing required packages
pip install -r requirements.txt
```

## Configuration
### Profiles
For local development you will have to configure `~/.dbt/profiles.yml` file,  
example of the profiles is provided in `.profiles` directory,  

alternatively, to create `profiles.yml` in `.profiles` directory, and include `DBT_PROFILES_DIR=./.profiles` in .env file.  

### Env
Create a new file called `.env`, and set some Environment variables in that file. 
Example of the variables that could be set is provided in `.env.example`

## Preparation
Need to run this on start of each session

### Linux and MacOS
```bash
source dbt-env/bin/activate
export $(grep -v '^#' .env | xargs)
```
### Windows
```cmd
dbt-env\Scripts\activate.bat
for /F "eol=# tokens=*" %i in (.env) do @set %i
```

## Debug
```
dbt debug
```

## Seed
```
dbt seed
```

## Run
```
dbt run
```

## Run Tests
```
dbt test
```

### Generate Docs
```
dbt docs generate
dbt docs serve
```
then access http://localhost:8080 on web browser.
