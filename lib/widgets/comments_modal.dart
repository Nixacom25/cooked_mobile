import 'package:flutter/material.dart';
import 'package:app_ecommerce/widgets/login_modal.dart';
import 'package:app_ecommerce/services/auth_service.dart';
import 'package:app_ecommerce/models/product.dart';
import 'package:app_ecommerce/services/product_service.dart';
import 'package:app_ecommerce/utils/date_formatter.dart';

class CommentsModal extends StatefulWidget {
  final int count;
  final String? productId;
  final String? productTitle;

  const CommentsModal({
    super.key,
    this.count = 30,
    this.productId,
    this.productTitle,
  });

  static Future<void> show(
    BuildContext context, {
    int count = 30,
    String? productId,
    String? productTitle,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsModal(
        count: count,
        productId: productId,
        productTitle: productTitle,
      ),
    );
  }

  @override
  State<CommentsModal> createState() => _CommentsModalState();
}

class _CommentsModalState extends State<CommentsModal> {
  final TextEditingController _commentController = TextEditingController();
  List<ProductComment> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    if (widget.productId == null) {
      setState(() => _isLoading = false);
      return;
    }

    // Get clientId for filtering unapproved comments
    final user = AuthService().currentUser.value;
    final clientId = user != null
        ? '${user['firstName']} ${user['lastName']}'
        : 'client123';

    final comments = await ProductService.getComments(
      widget.productId!,
      clientId: clientId,
    );
    if (mounted) {
      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleCommentSubmit() async {
    if (!AuthService().isLoggedIn.value) {
      LoginModal.show(context);
      return;
    }

    final text = _commentController.text.trim();
    if (text.isEmpty || widget.productId == null) return;

    // Use the actual logged-in user name/id if available, fallback to client123
    final user = AuthService().currentUser.value;
    final clientId = user != null
        ? '${user['firstName']} ${user['lastName']}'
        : 'client123';

    final newComment = await ProductService.addComment(
      widget.productId!,
      text,
      clientId: clientId,
    );

    if (newComment != null && mounted) {
      setState(() {
        _comments.insert(0, newComment);
        _commentController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 12, 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24), // Spacer for centering title
                    Text(
                      'Commentaires (${_isLoading ? "..." : _comments.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E2832),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Pour passer commande on aura besoin de votre : numéro sénégalais joignable ? et votre adresse ? et à quelle heure vous voulez l\'avoir ?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Comments List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF6F00)),
                  )
                : _comments.isEmpty
                ? const Center(
                    child: Text('Aucun commentaire pour ce produit.'),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _comments.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      final comment = _comments[index];
                      final initial = comment.clientId.isNotEmpty
                          ? comment.clientId[0].toUpperCase()
                          : 'U';
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey[200],
                            radius: 18,
                            child: Text(
                              initial,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      comment.clientId,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color(0xFF1E2832),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateFormatter.formatTimeAgo(
                                        comment.createdAt,
                                      ),
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  comment.content,
                                  style: const TextStyle(
                                    color: Color(0xFF4B5563),
                                    fontSize: 14,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          const Divider(height: 1),
          // Input Field
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              12 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Ajouter un commentaire...',
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _handleCommentSubmit,
                  icon: const Icon(
                    Icons.send_rounded,
                    color: Color(0xFFFF6F00),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
