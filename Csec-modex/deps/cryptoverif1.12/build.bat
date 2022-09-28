cd src

ocamlyacc parser.mly
ocamllex lexer.mll
ocamlyacc oparser.mly
ocamllex olexer.mll
ocamlc -o ..\cryptoverif.exe str.cma parsing_helper.mli parsing_helper.ml ptree.mli parser.mli parser.ml lexer.ml oparser.mli oparser.ml olexer.ml types.ml binderset.mli binderset.ml settings.mli settings.ml terms.mli terms.ml stringmap.mli stringmap.ml syntax.mli syntax.ml polynom.mli polynom.ml display.mli display.ml displaytex.mli displaytex.ml computeruntime.mli computeruntime.ml transform.mli transform.ml check.mli check.ml proba.mli proba.ml facts.mli facts.ml simplify1.mli simplify1.ml mergebranches.mli mergebranches.ml simplify.mli simplify.ml cryptotransf.mli cryptotransf.ml insertinstruct.mli insertinstruct.ml success.mli success.ml invariants.mli invariants.ml instruct.mli instruct.ml main.ml

cd ..
