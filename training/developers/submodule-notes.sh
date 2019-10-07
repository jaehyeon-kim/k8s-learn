git submodule add https://github.com/jaehyeon-kim/kfd-flask.git examples/developers/kfd-flask
git submodule add https://github.com/jaehyeon-kim/kfd-nodejs.git examples/developers/kfd-nodejs
git submodule add https://github.com/jaehyeon-kim/kfd-celery.git examples/developers/kfd-celery

### remove submodule
# Delete the relevant line from the .gitmodules file.
# Delete the relevant section from .git/config.
# Run git rm --cached path_to_submodule (no trailing slash).
# Commit the superproject.
# Delete the now untracked submodule files.

cat .gitmodules
# [submodule "examples/developers/kfd-flask"]
#         path = examples/developers/kfd-flask
#         url = https://github.com/jaehyeon-kim/kfd-flask.git
# [submodule "examples/developers/kfd-nodejs"]
#         path = examples/developers/kfd-nodejs
#         url = https://github.com/jaehyeon-kim/kfd-nodejs.git
# [submodule "examples/developers/kfd-celery"]
#         path = examples/developers/kfd-celery
#         url = https://github.com/jaehyeon-kim/kfd-celery.git

cat .git/config
# ...
# [submodule "apps/kfd-flask"]
#         url = https://github.com/jaehyeon-kim/kfd-flask.git
#         active = true
# [submodule "apps/kfd-nodejs"]
#         url = https://github.com/jaehyeon-kim/kfd-nodejs.git
#         active = true
# [submodule "apps/kfd-celery"]
#         url = https://github.com/jaehyeon-kim/kfd-celery.git
#         active = true

# first time
git submodule update --init --recursive
# subsequently
git pull --recurse-submodules

cd apps/kfd-flask
git fetch --tags # git fetch --all
git checkout tags/first_container