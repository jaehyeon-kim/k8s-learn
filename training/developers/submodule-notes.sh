git submodule add https://github.com/jaehyeon-kim/kfd-flask.git apps/kfd-flask
git submodule add https://github.com/jaehyeon-kim/kfd-nodejs.git apps/kfd-nodejs
git submodule add https://github.com/jaehyeon-kim/kfd-celery.git apps/kfd-celery

### remove submodule
# Delete the relevant line from the .gitmodules file.
# Delete the relevant section from .git/config.
# Run git rm --cached path_to_submodule (no trailing slash).
# Commit the superproject.
# Delete the now untracked submodule files.

cat .gitmodules
# [submodule "apps/kfd-flask"]
#         path = apps/kfd-flask
#         url = https://github.com/jaehyeon-kim/kfd-flask.git
# [submodule "apps/kfd-nodejs"]
#         path = apps/kfd-nodejs
#         url = https://github.com/jaehyeon-kim/kfd-nodejs.git
# [submodule "apps/kfd-celery"]
#         path = apps/kfd-celery
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