sourceurl="svn://svn.code.sf.net/p/qwt/code"
mirrorurl="git@github.com:mbdevpl/qwt.git"

mkdir qwt-mirror
cd qwt-mirror
git init

git svn -t tags -b branches -T trunk init "$sourceurl"
git svn fetch

git remote add github "${mirrorurl}"
git checkout -b trunk
git push github trunk

git for-each-ref --format="%(refname:short)" refs/remotes/origin/qwt* | cut -d / -f 2- |
while read ref
do
    git checkout -b "$ref" "origin/$ref"
    git push github "$ref"
done

git for-each-ref --format="%(refname:short) %(objectname)" refs/remotes/origin/tags | cut -d / -f 3- |
while read ref
do
    noprefix="${ref#qwt-}"
    git tag -a v${noprefix} -m "version ${noprefix%% *}"
done

git push github $(git tag)

git branch -d master
git checkout --orphan master
git rm -rf .
touch ".gitignore"
git add ".gitignore"
git commit -m "initial commit"
git merge --no-edit trunk
git push github master
