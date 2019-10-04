git submodule add https://github.com/kubernetes-for-developers/kfd-flask.git training/developers/modules/kfd-flask
git submodule add https://github.com/kubernetes-for-developers/kfd-nodejs.git training/developers/modules/kfd-nodejs
git submodule add https://github.com/kubernetes-for-developers/kfd-celery.git training/developers/modules/kfd-celery

Delete the relevant line from the .gitmodules file.
Delete the relevant section from .git/config.
Run git rm --cached path_to_submodule (no trailing slash).
Commit the superproject.
Delete the now untracked submodule files.

cat .gitmodules
# [submodule "training/developers/modules/kfd-flask"]
#         path = training/developers/modules/kfd-flask
#         url = https://github.com/kubernetes-for-developers/kfd-flask.git
# [submodule "training/developers/modules/kfd-nodejs"]
#         path = training/developers/modules/kfd-nodejs
#         url = https://github.com/kubernetes-for-developers/kfd-nodejs.git
# [submodule "training/developers/modules/kfd-celery"]
#         path = training/developers/modules/kfd-celery
#         url = https://github.com/kubernetes-for-developers/kfd-celery.git

cat .git/config
# ...
# [submodule "training/developers/modules/kfd-flask"]
#         url = https://github.com/kubernetes-for-developers/kfd-flask.git
#         active = true
# [submodule "training/developers/modules/kfd-nodejs"]
#         url = https://github.com/kubernetes-for-developers/kfd-nodejs.git
#         active = true
# [submodule "training/developers/modules/kfd-celery"]
#         url = https://github.com/kubernetes-for-developers/kfd-celery.git
#         active = true

# first time
git submodule update --init --recursive
# subsequently
git pull --recurse-submodules