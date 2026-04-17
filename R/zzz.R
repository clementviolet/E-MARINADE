.check_remote_version <- function(pkgname,
                                  owner = "clementviolet",
                                  repo = "ANIS-E",
                                  ref = "master") {
  
  url_remote <- sprintf(
    "https://raw.githubusercontent.com/%s/%s/refs/heads/%s/DESCRIPTION",
    owner, repo, ref
  )
  
  remote_ver <- tryCatch({
    con <- url(url_remote, open = "rb")
    on.exit(try(close(con), silent = TRUE), add = TRUE)
    
    txt <- readLines(con, warn = FALSE, encoding = "UTF-8")
    
    tc <- textConnection(txt)
    on.exit(try(close(tc), silent = TRUE), add = TRUE)
    
    desc <- read.dcf(tc)
    as.character(desc[1, "Version"])
  }, error = function(e) {
    NULL
  })
  
  local_ver <- as.character(utils::packageVersion(pkgname))
  
  packageStartupMessage(sprintf("%s v%s", pkgname, local_ver))
  
  if (!is.null(remote_ver) &&
      utils::compareVersion(remote_ver, local_ver) > 0) {
    
    packageStartupMessage(
      paste0(
        "A newer version of ", pkgname, " is available on GitHub: v", remote_ver, "\n",
        "Update with:\n",
        "  remotes::install_github('", owner, "/", repo, "@", ref, "')"
      )
    )
  }
  
  invisible(NULL)
}

.onAttach <- function(libname, pkgname) {
  
  if (!interactive()) return(invisible())
  
  .check_remote_version(pkgname = pkgname)
  
}