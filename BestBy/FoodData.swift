//
//  FoodData.swift
//  BestBy
//
//  Created by Erin Jensby on 2/18/18.
//
//  Copyright © 2018 Quatro. All rights reserved.
//

import Foundation

struct FoodData {
    
    static let food_data:[String:(Int,String)] =
        ["apples": (45, "Apples stored in the fridge can last 1 to 2 months.  When the apple gets a grainy, soft interior and wrinkled skin or bruising the apple has gone bad."),
         "asparagus": (6, "Asparagus stored in the fridge can last 5 to 7 days.  When the tips of the asparagus become dark green or black and are mushy or slimy the asparagus has gone bad. If the asparagus is left long enough it can grow mold as well."),
         "avocados": (8, "Avocados stored in the fridge can last 7 to 10 days.  An avocado has gone bad once the inside is no longer green and will turn brown.  You can often tell it has gone bad before cutting into it if it has become so soft a light press leaves an indentation."),
         "bananas": (6, "Bananas should be stored on the counter or on a banana stand.  Bananas that are going bad will have a large amount of the skin covered in brown spots and a softer texture.  Eventually they will turn completely brown and leak liquid and even grow mold."),
         "blueberries": (8, "Blueberries stored in the fridge can last 5 to 10 days.  Blueberries that are going bad will beging to soften and have a mushy texture and some discoloration and bruising.  They will then grow mold and need to be thrown out."),
         "broccoli": (10, "Broccoli stored in the fridge can last 7 to 14 days.  When broccoli start to go bad the texture will become more limp and the color will start to yellow.  You may also notice an intensified smell."),
         "butter":(90, "It can be hard to tell if butter has gone bad. Butter that is spoiled may begin to look paler or smell stale or cheesy."),
         "carrots": (28, "Carrots stored in the fridge can last 3 to 5 weeks.  When carrots are going bad they will develop a tiny white dots on the surface caused by dehydration.  Once they have become mushy or slimy they should not be eaten."),
         "cauliflower": (14, "Cauliflower stored in the fridge can last 1 to 3 weeks.  As cauliflower starts to go bad brown spots will begin to appear.  The cauliflower has gone bad if these spots spread or if the cauliflower has a moist or slimy texture."),
         "celery": (24, "Celery stored in the fridge can last 3 to 4 weeks. Celery that is going bad will become softer, hollow, and the color will become more yellow."),
         "corn": (6, "Corn stored in the fridge can last 5 to 7 days.  Corn that has gone bad will grow mold on the tip."),
         "cucumber": (7, "Cucumber stored in the fridge can last 7 to 10 days.  Cucumbers that are going bad will start developing soft spots and wrinkled skin.  If there is moisture or slime on the surface or if the texture has become mushy the cucumber has gone bad and should no longer be eaten."),
         "eggs": (35, "If there is a slight rotten odor when the egg is cracked it has spoiled.  You can also tell an egg has spoiled if the egg white has a pinkish or iridescent color."),
         "grapes": (8, "Grapes stored in the fridge can last 5 to 10 days.  Grapes that are going bad will begin to have a softer texture and brown discoloration.  If grapes have mold or a vinegar smell they have gone bad and need to be thrown out."),
         "green beans": (6, "Green beans stored in the fridge typically last 5 to 7 days.  When the green beans have become limp or moist they have gone bad."),
         "kale": (10, "Kale stored in the fridge typically lasts 1 to 2 weeks. When kale begins to go bad the color will become more yellow."),
         "leaf lettuce": (6, "Leaf lettuce stored in the fridge typically lasts 5 to 7 days.  If your lettuce begins to discolor, has a moist texture, or a rotten smell it has gone bad."),
         "lemons": (45, "Lemons can last 1 to 2 months in the fridge.  Lemons that are going bad have a soft texture and some discoloration.  If the lemon develops a soft spot or mold it needs to be thrown out."),
         "limes": (45, "Limes can last 1 to 2 months in the fridge.  Limes that are going bad have a softer texture and a light brown colored discoloration on the skin.  The inside of the lime will also begin to dry out."),
         "milk": (21, "Milk is typically still good for 5-7 days past the sell-by date. Milk that is discolored, lumpy, or has a sour odor has gone bad."),
         "oranges": (45, "Oranges stored in the fridge can last 1 to 2 months.  Bad oranges will have a soft texture and some discoloration.  If the orange develops a soft spot or mold it need to be thrown out.  Bad oranges will also have a sour smell and taste."),
         "peaches": (4, "Peaches in the fridge last 4-5 days.  Bad peaches will develop soft spots, overall softness, discoloration, and leaking."),
         "pears": (8, "Pears in the fridge can last 5 to 12 days.  Bad pears will have multiple brown bruises or blemishes and a soft or brown center."),
         "pineapples": (4, "Pineapples last 3 to 4 days and fridge storage is not necessary. Bad pineapples can have a soft or wet bottom, a sour, vinegar-like smell, darkened coloring, or a softer texture."),
         "pomegranates": (21, "A whole pomegranate can last 3 weeks in the fridge.  Once the seeds are removed they should be eaten in 5-7 days.  Update your pomegranates expiry reminder if you don't eat the seeds right away.  Pomegranates that have gone bad can be brown, brittle, or soft and the seeds may turn brown."),
         "strawberries": (7, "Strawberries can last 5 to 7 days in the fridge.  Strawberries will be softer and discolored or bruised as they spoil.  If the strawberries grow mold they are bad and should be thrown out."),
         "sour cream": (30, "Sour Cream typically lasts 1-2 weeks past the printed date.  If the water in your sour cream begins to seperate you should finish it in the next few days.  If you see bright bacterial marks, dark mold, or notice a bitter flavor the sour cream has gone bad."),
         "tomatoes": (12, "Tomatoes stored in the fridge can last 2 weeks.  Tomatoes will get softer and may leak fluid as they go bad. If the tomatoes grow mold they are bad and should be thrown out."),
         "watermelon": (18, "Watermelon can last 2 to 3 weeks when stored in the fridge, if kept on the counter it will last 7-10 days.  A watermelon that has spoiled will have a soft, grainy texture, darken coloring, and have an excess of fluid in the center."),
         "yogurt": (21, "Yogurt is typically still good for 7-10 days past the printed date. If you notice a curdling texture near the bottom of the container or an excess of liquid on the surface the yogurt is going bad.  If there is mold on the yogurt it has gone bad and must be thrown out."),
        "iceburg lettuce": (7, "Iceburg lettuce stored in the fridge typically lasts 7 to 10 days.  If your lettuce begins to discolor, has a moist texture, or a rotten smell it has gone bad."),
        "romaine lettuce": (7, "Romaine lettuce stored in the fridge typically lasts 7 to 10 days.  If your lettuce begins to discolor, has a moist texture, or a rotten smell it has gone bad."),
        "mushrooms": (7, "Mushrooms stored in the fridge typically last 7 to 10 days.  Ifthe mushrooms begin to get sticky or slimy they are going bad and could be growing mold."),
        "onions": (45, "Onions can typically last in the fridge 1 to 2 months. Onions that are going bad will begin to develop soft spots or black or brown spots."),
        "green bell peppers": (14, "Green Bell Peppers can last 2 to 3 weeks stored in the fridge.  When bell peppers begin to go bad they will become softer and get wrinkly skin. Bell peppers have gone bad when they become slimy or mold has developed."),
        "red bell peppers": (10, "Red Bell Peppers can last 1 to 2 weeks stored in the fridge.  When bell peppers begin to go bad they will become softer and get wrinkly skin. Bell peppers have gone bad when they become slimy or mold has developed."),
        "orange bell peppers": (10, "Orange Bell Peppers can last 1 to 2 weeks stored in the fridge.  When bell peppers begin to go bad they will become softer and get wrinkly skin. Bell peppers have gone bad when they become slimy or mold has developed."),
        "yellow bell peppers": (10, "Yellow Bell Peppers can last 1 to 2 weeks stored in the fridge.  When bell peppers begin to go bad they will become softer and get wrinkly skin. Bell peppers have gone bad when they become slimy or mold has developed."),
        "russet potatoes": (28, "Russet Potatoes stored in the pantry can last 3 to 5 weeks.  They can also be stored in the fridge to extend their shelf life to 3 to 4 months but may develop a sweeter taste.  Potatoes going bad will get softer and have discoloration and white sprouts on the skin.  These sprouts can be cut off and the potato still eaten when they are small and just starting"),
        "white potatoes": (28, "White Potatoes stored in the pantry can last 3 to 5 weeks.  They can also be stored in the fridge to extend their shelf life to 3 to 4 months but may develop a sweeter taste.  Potatoes going bad will get softer and have discoloration and white sprouts on the skin.  These sprouts can be cut off and the potato still eaten when they are small and just starting"),
        "yukon gold potatoes": (18, "Yukon Gold Potatoes stored in the pantry can last 2 to 3 weeks.  They can also be stored in the fridge to extend their shelf life to 2 to 3 months but may develop a sweeter taste.  Potatoes going bad will get softer and have discoloration and white sprouts on the skin.  These sprouts can be cut off and the potato still eaten when they are small and just starting"),
        "red potatoes": (18, "Red Potatoes stored in the pantry can last 2 to 3 weeks.  They can also be stored in the fridge to extend their shelf life to 2 to 3 months but may develop a sweeter taste.  Potatoes going bad will get softer and have discoloration and white sprouts on the skin.  These sprouts can be cut off and the potato still eaten when they are small and just starting"),
        "fingerling potatoes": (18, "Fingerling Potatoes stored in the pantry can last 2 to 3 weeks.  They can also be stored in the fridge to extend their shelf life to 2 to 3 months but may develop a sweeter taste.  Potatoes going bad will get softer and have discoloration and white sprouts on the skin.  These sprouts can be cut off and the potato still eaten when they are small and just starting"),
        "sweet potatoes": (28, "Sweet Potatoes stored in the pantry can last 3 to 5 weeks.  They can also be stored in the fridge to extend their shelf life to 3 to 4 months but may develop a sweeter taste.  Potatoes going bad will get softer and have discoloration and white sprouts on the skin.  These sprouts can be cut off and the potato still eaten when they are small and just starting"),
        "winter squash": (62, "Winter Squash stored on the counter or in the fridge can last 1 to 3 months.  When squash begins to go bad it will get softer and begin to leak liquid.  If the squash has grown mold it has gone bad and should be thrown out."),
        "spaghetti squash": (62, "Spaghetti Squash stored on the counter or in the fridge can last 1 to 3 months.  When squash begins to go bad it will get softer and begin to leak liquid.  If the squash has grown mold it has gone bad and should be thrown out."),
        "zucchini": (5, "Zucchini stored in the fridge can last 5 to 7 days.  When zucchini begins to go bad it will be softer and black marks may appear on the skin.  When the zucchini gets mushy or a thick white liquid appears on the skin it has gone bad and should be thrown out."),
        "summer squash": (5, "Summer Squash stored in the fridge can last 5 to 7 days.  When summer squash begins to go bad it will be softer and black marks may appear on the skin.  When the summer squash gets mushy or a thick white liquid appears on the skin it has gone bad and should be thrown out."),
        "butter lettuce": (4, "Butter lettuce stored in the fridge typically lasts 3 to 5 days.  If your lettuce begins to discolor, has a moist texture, or a rotten smell it has gone bad."),
        "butternut squash": (62, "Butternut Squash stored on the counter or in the fridge can last 1 to 3 months.  When squash begins to go bad it will get softer and begin to leak liquid.  If the squash has grown mold it has gone bad and should be thrown out.")
         ]
    
}
