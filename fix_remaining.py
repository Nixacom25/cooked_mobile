with open('lib/screens/onboarding/onboarding_screen.dart', 'r') as f:
    lines = f.readlines()

def replace_at(start_idx, replacement):
    end_idx = start_idx
    while ");" not in lines[end_idx]:
        end_idx += 1
    for i in range(start_idx, end_idx):
        lines[i] = ""
    lines[end_idx] = replacement + "\n"

# 457: _pageController.animateToPage(30
replace_at(456, "      _pageController.jumpToPage(30);")

# 609: _pageController.animateToPage(31
replace_at(608, "        _pageController.nextPage();")

# 615: _pageController.animateToPage(32
replace_at(614, "        _pageController.jumpToPage(32);")

# 879: _pageController.animateToPage(33
replace_at(878, "                              _pageController.nextPage();")

# 921: _pageController.animateToPage(35
replace_at(920, "                          _pageController.nextPage();")

# 930: _pageController.animateToPage(36
replace_at(929, "                          _pageController.nextPage();")

# 1037: _pageController.animateToPage(37
replace_at(1036, "                                _pageController.nextPage();")

with open('lib/screens/onboarding/onboarding_screen.dart', 'w') as f:
    f.writelines(lines)

