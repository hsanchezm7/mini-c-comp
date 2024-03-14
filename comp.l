
%x COMENTARIO
%%
"/*"                    { BEGIN(COMENTARIO); }
<COMENTARIO>(.|\n)      ;
<COMENTARIO>"*/"        { BEGIN(0); }

%%