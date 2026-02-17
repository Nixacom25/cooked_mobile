import 'package:app_ecommerce/models/product.dart';

class MockDatabase {
  static const List<Product> products = [
    Product(
      id: '1',
      title: 'Fashion Mix',
      price: '15,000 FCFA',
      originalPrice: '30,000 FCFA',
      promoLabel: 'PROMO',
      description:
          'Collection tendance de vêtements fashion. Matériaux de qualité premium, design moderne et confortable. Disponible en plusieurs tailles et couleurs. Parfait pour toutes occasions.',
      videoUrls: [
        'https://res.cloudinary.com/prod/video/upload/du_6/fl_splice:transition_(name_fade;du_2),l_video:me:fashion-2/du_6/fl_layer_apply/me/fashion-1.mp4',
      ],
      thumbnailUrl:
          'https://images.unsplash.com/photo-1483985988355-763728e1935b?auto=format&fit=crop&q=80&w=400',
      category: 'Fashion',
    ),
    Product(
      id: '2',
      title: 'Luxury Perfume',
      price: '45,000 FCFA',
      description:
          'Parfum de luxe aux notes florales et boisées. Longue tenue, flacon élégant. Senteur raffinée pour homme et femme. Cadeau idéal.',
      videoUrls: [
        'https://res.cloudinary.com/prod/video/upload/du_6/fl_splice:transition_(name_hblur;du_2),l_video:me:perfume-2/du_6/fl_layer_apply/me/perfume-1.mp4',
      ],
      thumbnailUrl:
          'https://images.unsplash.com/photo-1523293182086-7651a899d37f?auto=format&fit=crop&q=80&w=400',
      category: 'Beauty',
    ),
    Product(
      id: '3',
      title: 'Extreme Sport',
      price: '25,000 FCFA',
      originalPrice: '50,000 FCFA',
      promoLabel: '-50%',
      description:
          'Équipement sportif haute performance. Matériaux techniques, résistant et léger. Parfait pour running, fitness, et sports extrêmes. -50% de réduction !',
      videoUrls: [
        'https://res.cloudinary.com/prod/video/upload/du_12/fl_splice:transition_(name_pixelize;du_2),l_video:me:sport-2/du_12/fl_layer_apply/me/sport-1.mp4',
      ],
      thumbnailUrl:
          'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&q=80&w=400',
      category: 'Sport',
    ),
    Product(
      id: '4',
      title: 'Abstract Art',
      price: '30,000 FCFA',
      description:
          'Haltères ajustables de qualité professionnelle. Parfait pour vos séances de musculation à la maison.',
      videoUrls: [
        'https://res.cloudinary.com/prod/video/upload/du_10/fl_splice:transition_(name_fade;du_2),l_video:me:dumbbell-2/du_10/fl_layer_apply/me/dumbbell-1.mp4',
      ],
      thumbnailUrl:
          'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?auto=format&fit=crop&q=80&w=400',
      category: 'Sport',
      images: [
        'https://images.unsplash.com/photo-1584735935682-2f2b69dff9d2?auto=format&fit=crop&q=80&w=400',
        'https://images.unsplash.com/photo-1638536532686-d610adfc8e5c?auto=format&fit=crop&q=80&w=400',
      ],
    ),
    Product(
      id: '5',
      title: 'Gourmet Burger',
      price: '5,000 FCFA',
      description:
          'Délicieux burger artisanal avec viande fraîche et ingrédients locaux.',
      videoUrls: [
        'https://res.cloudinary.com/prod/video/upload/du_10/fl_splice:transition_(name_dissolve;du_2),l_video:me:abstract-2/du_10/fl_layer_apply/me/abstract-1.mp4',
      ], // Example video
      thumbnailUrl:
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&q=80&w=400',
      category: 'Food',
      images: [
        'https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&q=80&w=400',
        'https://images.unsplash.com/photo-1606755962773-d324e0a13086?auto=format&fit=crop&q=80&w=400',
      ],
    ),
    Product(
      id: '6',
      title: 'Sushi Set',
      price: '12,000 FCFA',
      description: 'Assortiment de sushis frais préparés par nos chefs.',
      videoUrls: [
        'https://res.cloudinary.com/prod/video/upload/du_6/fl_splice:transition_(name_hblur;du_2),l_video:me:perfume-2/du_6/fl_layer_apply/me/perfume-1.mp4',
      ], // Example video
      thumbnailUrl:
          'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&q=80&w=400',
      category: 'Food',
    ),
    Product(
      id: '7',
      title: 'Pizza Italienne',
      price: '8,000 FCFA',
      description: 'Pizza authentique cuite au feu de bois.',
      videoUrls: [
        'https://res.cloudinary.com/prod/video/upload/du_6/fl_splice:transition_(name_fade;du_2),l_video:me:fashion-2/du_6/fl_layer_apply/me/fashion-1.mp4',
      ], // Example video
      thumbnailUrl:
          'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&q=80&w=400',
      category: 'Food',
    ),
  ];

  static List<Product> getProductsByCategory(String category) {
    if (category == 'All') return products;
    // For demo purposes, just return a subset or shuffled version if category matches loosely,
    // or return all if we want to fill the UI
    return products;
  }
}
