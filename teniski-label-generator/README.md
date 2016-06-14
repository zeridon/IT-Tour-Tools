Label generator
===============
Tooling and automation around generating labels for preordered t-shirts

Prerequisites
-------------
* Inkscape
* Imagemagic (convert speciffically)
* popler-utils (pdfunite)
* labelmaker (https://github.com/ducky64/labelmaker)
 * configparser (pip)
 * pillow (pip)
* Python (preferably 3 or you will have issues with unicode)
* python virtualenv (or install necessities system wide)

Prerequisite Artifacts
----------------------
* `template_teniski_etiketi.svg` - a single label template
* `65mm_x_40mm_3x8.ini` - config file describing the paper sheet and layout of the labels
* `logo_500x500.png` - a logo
* `teniski.csv` - csv files with your entries

Usage
-----
```
./build.sh
```

Input data format (teniski.csv)
-------------------------------
The input csv file `teniski.csv` should have 5 columns

```
Timestamp,name,kroika,color,razmer
6/13/2016 14:26:46,Some Name,Male Fit,Pink,L
```

What the tool does
------------------
* convert logo to grayscale and transparent (better your background be white)
* create a temporary template from `template_teniski_etiketi.svg` that has the proper logo
* strip the first line of the input data `teniski.csv` and replace it with our header
* generate several pages of svg labels
* convert those generated pages to eps, png, pdf
* merge all the pdf's into a single file `teniski_etiketi.pdf`
