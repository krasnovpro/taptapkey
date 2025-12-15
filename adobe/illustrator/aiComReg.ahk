#NoTrayIcon
#SingleInstance force

appName := A_Args[1]
appPath := A_Args[2]
progID  := A_Args[3]
clsID   := A_Args[4]
typeLib := A_Args[5]

h := "HKCR\CLSID\{" clsID "}"

for k, v in Map(
  h                             , appName                       ,
  h "\LocalServer32"            , appPath " /Automation"        ,
  h "\ProgID"                   , progID                        ,
  h "\Programmable"             , ""                            ,
  h "\TypeLib"                  , typeLib                       ,
  h "\VersionIndependentProgID" , StrReplace(appName, " ", ".") ,
  "HKCR\" progID                , appName                       ,
  "HKCR\" progID "\CLSID"       , "{" clsID "}"                 ,
) {
  try {
    RegWrite(v, "REG_SZ", k)
  } catch {
    ExitApp(-1)
  }
}