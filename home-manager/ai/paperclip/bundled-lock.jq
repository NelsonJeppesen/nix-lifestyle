# Make Paperclip's npm lock acceptable to `npm ci`.
#
# Some packages in the release ship their dependencies as bundles (lock
# entries marked inBundle). A few bundled entries declare dependencies the
# bundle does not contain: macOS-only optional packages such as fsevents, and
# exact-version pins on a package the bundle ships at another version. npm
# install tolerates these broken edges, but `npm ci` reports the lock as out
# of sync with package.json.
#
# For each bundled entry, resolve every dependency the way Node does (nearest
# node_modules upwards). Drop optional dependencies that resolve nowhere, and
# point mismatched exact pins at the version that resolves, which is the copy
# Node loads at runtime. Entries outside bundles are left untouched.
def parent_dirs($key):
  ($key | split("/node_modules/")) as $parts
  | [range($parts | length; 0; -1) as $i | ($parts[:$i] | join("/node_modules/"))];

def resolve($pkgs; $key; $name):
  first(
    parent_dirs($key)[] as $dir
    | ($dir + "/node_modules/" + $name) as $candidate
    | select($pkgs[$candidate] != null)
    | $candidate
  ) // (("node_modules/" + $name) as $top | if $pkgs[$top] != null then $top else null end);

.packages as $pkgs
| .packages |= with_entries(
    if .value.inBundle then
      .key as $key
      | if .value.optionalDependencies then
          .value.optionalDependencies |= with_entries(select(resolve($pkgs; $key; .key) != null))
          | if .value.optionalDependencies == {} then del(.value.optionalDependencies) else . end
        else . end
      | if .value.dependencies then
          .value.dependencies |= with_entries(
            resolve($pkgs; $key; .key) as $resolved
            | if $resolved != null
                and (.value | test("^[0-9]+\\.[0-9]+\\.[0-9]+$"))
                and $pkgs[$resolved].version != .value
              then .value = $pkgs[$resolved].version
              else . end)
        else . end
    else . end)
