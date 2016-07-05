# solrevdev.github.io
Static Jekyll TinyPress driven website to replace solrevdev.com blogger account

## jekyll commands used to get setup

```shell
sudo chown -R $(whoami) /usr/local

sudo chown -R $(whoami) /Library/Ruby

brew install ruby

gem install bundler

gem install rouge

gem update --system

sudo gem cleanup

bundle install

bundle exec jekyll serve

gem install jekyll-import

ruby -rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::Blogger.run({
      "source"                => "_blogger.xml",
      "no-blogger-info"       => false, # not to leave blogger-URL info (id and old URL) in the front matter
      "replace-internal-link" => false, # replace internal links using the post_url liquid tag.
    })'


bundle exec htmlproofer ./_site

bundle exec htmlproofer ./_site --check-html --disable-external --checks-to-ignore ImageCheck,LinkCheck, HtmlCheck

bundle exec htmlproofer ./_site --disable-external --checks-to-ignore ImageCheck,LinkCheck,HtmlCheck

htmlproofer ./_site


```

## travis and github custom domain resources

* http://sgoettschkes.me/p/deploying-a-jekyll-website-to-github-pages-using-travisci.html
* http://intenseagile.com/2015/04/27/running-jekyll-on-codeanywhere.html

* http://www.steveklabnik.com/automatically_update_github_pages_with_travis_example/
* http://awestruct.org/auto-deploy-to-github-pages/
* https://github.com/mbonaci/mbo-storm/wiki/Integrate-Travis-CI-with-your-GitHub-repo
* https://travis-ci.org/profile/solrevdev
* https://docs.travis-ci.com/user/for-beginners
* https://docs.travis-ci.com/user/getting-started/
* https://help.github.com/articles/troubleshooting-custom-domains/#dns-configuration-errors
* https://help.github.com/articles/setting-up-a-www-subdomain/
* https://tinypress.co/settings
* https://github.com/blog/2100-github-pages-now-faster-and-simpler-with-jekyll-3-0
* https://github.com/solrevdev/solrevdev.github.io
* https://dnsimple.com/dashboard
* https://help.github.com/articles/troubleshooting-jekyll-builds/
* https://gist.github.com/razor-x/8166421
* https://github.com/mfenner/jekyll-travis




