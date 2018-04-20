$clean_ext = "aux bbl fls log nav out snm run.xml synctex.gz synctex.gz(busy) toc vrb xdv";

# Add synctex option to xelatex (https://tex.stackexchange.com/a/408788)

push @extra_xelatex_options, '-synctex=1' ;
