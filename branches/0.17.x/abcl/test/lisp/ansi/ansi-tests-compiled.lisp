(require 'asdf)
(handler-case 
    (progn
      (asdf:oos 'asdf:load-op :abcl :force t)
      (asdf:oos 'asdf:test-op :ansi-compiled :force t))
  (t (e) (warn "Exiting after catching ~A" e)))
(ext:exit)
  
      

