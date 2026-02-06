#show: doc => worldbuilders(
$if(title)$
  title: "$title$",
$else$
  title: none,
$endif$
$if(subtitle)$
  subtitle: "$subtitle$",
$else$
  subtitle: none,
$endif$
$if(version)$
  version: "$version$",
$else$
  version: none,
$endif$
$if(by-author)$
  authors: ($for(by-author)$"$it.name.literal$", $endfor$),
$else$
  authors: none,
$endif$
$if(date)$
  date: "$date$",
$else$
  date: none,
$endif$
$if(abstract)$
  abstract: "$abstract$",
$else$
  abstract: none,
$endif$
$if(columns)$
  cols: $columns$,
$else$
  cols: 1,
$endif$
$if(lang)$
  lang: "$lang$",
$else$
  lang: "en",
$endif$
$if(region)$
  region: "$region$",
$else$
  region: "US",
$endif$
$if(section-numbering)$
  section-numbering: "$section-numbering$",
$else$
  section-numbering: none,
$endif$
$if(toc)$
  toc: true,
$else$
  toc: false,
$endif$
$if(toc-title)$
  toc_title: "$toc-title$",
$else$
  toc_title: none,
$endif$
$if(toc-depth)$
  toc_depth: $toc-depth$,
$else$
  toc_depth: none,
$endif$
$if(logo-image)$
  logo-image: "$logo-image$",
$else$
  logo-image: none,
$endif$
$if(license-image)$
  license-image: "$license-image$",
$else$
  license-image: none,
$endif$
  doc,
)
