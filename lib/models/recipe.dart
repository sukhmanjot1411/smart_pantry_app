class Recipe {
  final String name;
  final String description;
  final List<String> ingredients;
  final String cookingTime;
  final String difficulty;

  Recipe({
    required this.name,
    required this.description,
    required this.ingredients,
    required this.cookingTime,
    required this.difficulty,
  });
}

final List<Recipe> recipes = [
  Recipe(
    name: 'Butter Chicken',
    description: 'Creamy and rich Indian curry with tender chicken pieces',
    ingredients: ['Chicken', 'Butter', 'Cream', 'Tomatoes', 'Spices'],
    cookingTime: '45 mins',
    difficulty: 'Medium',
  ),
  Recipe(
    name: 'Pasta Carbonara',
    description: 'Classic Italian pasta with creamy egg sauce and bacon',
    ingredients: ['Pasta', 'Eggs', 'Bacon', 'Parmesan', 'Black Pepper'],
    cookingTime: '30 mins',
    difficulty: 'Easy',
  ),
  Recipe(
    name: 'Vegetable Stir Fry',
    description: 'Quick and healthy Asian-style vegetable medley',
    ingredients: ['Mixed Vegetables', 'Soy Sauce', 'Ginger', 'Garlic', 'Oil'],
    cookingTime: '20 mins',
    difficulty: 'Easy',
  ),
  Recipe(
    name: 'Chicken Biryani',
    description: 'Aromatic Indian rice dish with spiced chicken',
    ingredients: ['Basmati Rice', 'Chicken', 'Onions', 'Spices', 'Yogurt'],
    cookingTime: '60 mins',
    difficulty: 'Hard',
  ),
  Recipe(
    name: 'Chocolate Cake',
    description: 'Rich and moist chocolate cake with ganache',
    ingredients: ['Flour', 'Cocoa', 'Sugar', 'Eggs', 'Butter'],
    cookingTime: '50 mins',
    difficulty: 'Medium',
  ),
  Recipe(
    name: 'Greek Salad',
    description: 'Fresh Mediterranean salad with feta cheese',
    ingredients: ['Cucumber', 'Tomatoes', 'Olives', 'Feta', 'Olive Oil'],
    cookingTime: '15 mins',
    difficulty: 'Easy',
  ),
  Recipe(
    name: 'Pizza Margherita',
    description: 'Classic Italian pizza with tomatoes and mozzarella',
    ingredients: ['Pizza Dough', 'Tomatoes', 'Mozzarella', 'Basil', 'Olive Oil'],
    cookingTime: '40 mins',
    difficulty: 'Medium',
  ),
  Recipe(
    name: 'Sushi Rolls',
    description: 'Japanese rice rolls with fresh fish and vegetables',
    ingredients: ['Sushi Rice', 'Nori', 'Fish', 'Avocado', 'Cucumber'],
    cookingTime: '45 mins',
    difficulty: 'Hard',
  ),
  Recipe(
    name: 'Beef Burger',
    description: 'Juicy homemade beef burger with fresh toppings',
    ingredients: ['Ground Beef', 'Buns', 'Cheese', 'Lettuce', 'Tomato'],
    cookingTime: '25 mins',
    difficulty: 'Medium',
  ),
  Recipe(
    name: 'Thai Green Curry',
    description: 'Spicy and aromatic coconut curry with vegetables',
    ingredients: ['Coconut Milk', 'Green Curry Paste', 'Vegetables', 'Chicken', 'Thai Basil'],
    cookingTime: '35 mins',
    difficulty: 'Medium',
  ),
];
