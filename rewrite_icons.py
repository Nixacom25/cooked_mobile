import re

with open("packages/font_awesome_flutter/lib/font_awesome_flutter.dart", "r") as f:
    content = f.read()

content = re.sub(r'IconDataBrands\((0x[0-9a-fA-F]+)\)', r"IconData(\1, fontFamily: 'FontAwesomeBrands', fontPackage: 'font_awesome_flutter')", content)
content = re.sub(r'IconDataRegular\((0x[0-9a-fA-F]+)\)', r"IconData(\1, fontFamily: 'FontAwesomeRegular', fontPackage: 'font_awesome_flutter')", content)
content = re.sub(r'IconDataSolid\((0x[0-9a-fA-F]+)\)', r"IconData(\1, fontFamily: 'FontAwesomeSolid', fontPackage: 'font_awesome_flutter')", content)

with open("packages/font_awesome_flutter/lib/font_awesome_flutter.dart", "w") as f:
    f.write(content)

