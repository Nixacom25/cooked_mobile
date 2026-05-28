import re

with open('lib/screens/home/home_screen.dart', 'r') as f:
    content = f.read()

# We want to replace everything from `class _HeaderState extends State<_Header> {` down to the end of that class.
# The class ends right before `// ── Search bar`
pattern = re.compile(r'class _HeaderState extends State<_Header> \{.*?(?=\n// ── Search bar)', re.DOTALL)

replacement = """class _HomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  final ValueChanged<String>? onSearchChanged;

  _HomeHeaderDelegate({this.onSearchChanged});

  @override
  double get maxExtent => 260.h;

  @override
  double get minExtent => 110.h;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double expandRatio = 1.0 - (shrinkOffset / (maxExtent - minExtent));
    final double safeExpandRatio = expandRatio.clamp(0.0, 1.0);

    return Container(
      color: Colors.white,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -shrinkOffset * 0.5,
            left: 0,
            right: 0,
            height: 240.h,
            child: Opacity(
              opacity: safeExpandRatio,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30.r),
                  bottomRight: Radius.circular(30.r),
                ),
                child: Container(
                  color: const Color(0xFFC83A2D),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Consumer<UserState>(
                                builder: (context, userState, _) {
                                  final user = userState.user;
                                  final photoUrl = user?.photo;
                                  final firstName = user?.firstname ?? 'Chef';

                                  return Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 24.r,
                                        backgroundColor: const Color(0xFFE5E7EB),
                                        backgroundImage: photoUrl != null
                                            ? NetworkImage(photoUrl)
                                            : null,
                                        child: photoUrl == null
                                            ? Icon(Icons.person, color: Colors.white, size: 28.sp)
                                            : null,
                                      ),
                                      SizedBox(width: 12.w),
                                      Text(
                                        'Hi, $firstName',
                                        style: TextStyle(
                                          fontFamily: 'SF Pro',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 20.sp,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const Spacer(),
                                      PopupMenuButton<String>(
                                        icon: Icon(Icons.more_vert_rounded, color: Colors.white, size: 28.sp),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                                        color: Colors.white,
                                        elevation: 8,
                                        onSelected: (value) async {
                                          if (value == 'settings') {
                                            Navigator.pushNamed(context, AppRoutes.profile);
                                          } else if (value == 'logout') {
                                            if (context.mounted) {
                                              await Provider.of<UserState>(context, listen: false).logout();
                                            }
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            value: 'settings',
                                            child: Row(
                                              children: [
                                                Icon(Icons.settings_outlined, color: const Color(0xFF1A1A1A), size: 20.sp),
                                                SizedBox(width: 12.w),
                                                Text('Settings', style: TextStyle(fontFamily: 'SF Pro', fontSize: 15.sp, color: const Color(0xFF1A1A1A))),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'logout',
                                            child: Row(
                                              children: [
                                                Icon(Icons.logout_rounded, color: const Color(0xFFC83A2D), size: 20.sp),
                                                SizedBox(width: 12.w),
                                                Text('Logout', style: TextStyle(fontFamily: 'SF Pro', fontSize: 15.sp, color: const Color(0xFFC83A2D))),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),
                          Padding(
                            padding: EdgeInsets.only(right: 30.w),
                            child: Text(
                              'What would you like to\\ncook today?',
                              style: TextStyle(fontFamily: 'SF Pro', fontWeight: FontWeight.w800, fontSize: 28.sp, color: const Color(0xFFFFF6D6), height: 1.25),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(top: 10.h),
              child: _SearchBar(onChanged: onSearchChanged),
            ),
          ),
        ],
      ),
    );
  }
}
"""

new_content = pattern.sub(replacement, content)

with open('lib/screens/home/home_screen.dart', 'w') as f:
    f.write(new_content)

print("Replaced!")
