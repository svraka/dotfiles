#!/usr/bin/env bash

for f in clusterdb createdb createlang createuser dropdb droplang dropuser initdb pg_basebackup pg_dump pg_dumpall pg_receivexlog pg_restore psql reindexdb vacuumdb; do
    mv "${pkgdir}"${MINGW_PREFIX}/bin/${f}.exe "${pkgdir}"${MINGW_PREFIX}/bin/${f}_exe
    _exename="${f}"
    echo "#!/usr/bin/env bash" > "${pkgdir}${MINGW_PREFIX}/bin/${_exename}"
    echo '/usr/bin/winpty "$( dirname ${BASH_SOURCE[0]} )/'${_exename}'.exe" "$@"' >> "${pkgdir}${MINGW_PREFIX}/bin/${_exename}"
    mv "${pkgdir}"${MINGW_PREFIX}/bin/${f}_exe "${pkgdir}"${MINGW_PREFIX}/bin/${f}.exe
done
