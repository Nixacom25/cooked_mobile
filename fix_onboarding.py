import re

with open('lib/screens/onboarding/onboarding_screen.dart', 'r') as f:
    content = f.read()

# 1. Imports
content = content.replace("import 'widgets/perfect_meal_step.dart';", "import 'widgets/perfect_meal_step.dart';\nimport 'package:flutter_page_curl/flutter_page_curl.dart';")

# 2. Controller definition
content = content.replace("late PageController _pageController;", "late PageCurlController _pageController;")

# 3. Init fallback
content = content.replace("_pageController = PageController(); // Initial fallback", "_pageController = PageCurlController(); // Initial fallback")

# 4. _pageController.nextPage(duration..., curve...) block (multi-line)
content = re.sub(r"_pageController\.nextPage\(\s*duration:.*?curve:.*?\);", "_pageController.nextPage();", content, flags=re.DOTALL)

# 5. _pageController.previousPage(duration..., curve...) block
content = re.sub(r"_pageController\.previousPage\(\s*duration:.*?curve:.*?\);", "_pageController.previousPage();", content, flags=re.DOTALL)

# 6. Init state jumpToPage block
content = re.sub(
    r"if \(_pageController\.hasClients\) \{\s*_pageController\.jumpToPage\(_currentPage\);\s*\} else \{\s*_pageController = PageController\(initialPage: _currentPage\);\s*\}",
    "_pageController = PageCurlController(initialPage: _currentPage);",
    content,
    flags=re.DOTALL
)

# 7. animateToPage to jumpToPage for skips
content = re.sub(r"_pageController\.animateToPage\(\s*30,\s*duration:.*?curve:.*?\);", "_pageController.jumpToPage(30);", content, flags=re.DOTALL)
content = re.sub(r"_pageController\.animateToPage\(\s*26,\s*duration:.*?curve:.*?\);", "_pageController.jumpToPage(26);", content, flags=re.DOTALL)

# 8. animateToPage to nextPage for adjacents
content = re.sub(r"_pageController\.animateToPage\(\s*28,\s*duration:.*?curve:.*?\);", "_pageController.nextPage();", content, flags=re.DOTALL)
content = re.sub(r"_pageController\.animateToPage\(\s*31,\s*duration:.*?curve:.*?\);", "_pageController.nextPage();", content, flags=re.DOTALL)
content = re.sub(r"_pageController\.animateToPage\(\s*32,\s*duration:.*?curve:.*?\);", "_pageController.jumpToPage(32);", content, flags=re.DOTALL)
content = re.sub(r"_pageController\.animateToPage\(\s*33,\s*duration:.*?curve:.*?\);", "_pageController.nextPage();", content, flags=re.DOTALL)
content = re.sub(r"_pageController\.animateToPage\(\s*35,\s*duration:.*?curve:.*?\);", "_pageController.nextPage();", content, flags=re.DOTALL)
content = re.sub(r"_pageController\.animateToPage\(\s*36,\s*duration:.*?curve:.*?\);", "_pageController.nextPage();", content, flags=re.DOTALL)
content = re.sub(r"_pageController\.animateToPage\(\s*37,\s*duration:.*?curve:.*?\);", "_pageController.nextPage();", content, flags=re.DOTALL)

# 9. PageView to PageCurlView
content = re.sub(
    r"PageView\(\s*controller: _pageController,\s*physics: const NeverScrollableScrollPhysics\(\),\s*onPageChanged: _onStepChanged,",
    "PageCurlView(\n                    controller: _pageController,\n                    edgeZoneWidth: 0.0,\n                    animationDuration: const Duration(milliseconds: 600),\n                    onPageChanged: _onStepChanged,",
    content,
    flags=re.DOTALL
)

with open('lib/screens/onboarding/onboarding_screen.dart', 'w') as f:
    f.write(content)

