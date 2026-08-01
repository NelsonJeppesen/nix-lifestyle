# dev home dir
hash -d s=~/source/

# Register project directories for expansion as ~name.
for dir in "$HOME"/source/*(ND-/) "$HOME"/source/personal/*(ND-/); do
  hash -d "${dir:t}"="$dir"
done
unset dir
