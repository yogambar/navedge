#ifndef KNAPSACK_H
#define KNAPSACK_H

#include <vector>

class Knapsack {
public:
    struct Item {
        int weight;
        int value;
    };

    // Solves the 0/1 Knapsack problem using Dynamic Programming
    static int solveKnapsack(int capacity, const std::vector<Item>& items);

    // Returns the selected items that contribute to the optimal solution
    static std::vector<int> getSelectedItems(int capacity, const std::vector<Item>& items);
};

#endif // KNAPSACK_H

