/*
main.do




*/

local wd: pwd
if substr("`wd'",10,8) == "lmostrom" {
	global repo "C:\Users\lmostrom\Documents\GitHub\pubmed_geography"
	global drop "C:\Users\lmostrom\Dropbox\pubmed_geography\"
}
if substr("`wd'",10,5) == "17036" {
	global repo "C:\Users\17036\OneDrive\Documents\GitHub\pubmed_geography"
	global drop "C:\Users\17036\Dropbox\pubmed_geography"
}

cd $drop

include $repo/pmidlist_assemble.do
sdf
include $repo/preqin_import.do
	