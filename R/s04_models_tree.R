# s04_models_trees.R


# Step 03 : Fit decision tree on a fiching season dataset.


# Project : machine_learning_examples_ete414
# Author  : Jeremie Boudreault
# Email   : Jeremie.Boudreault [at] inrs [dot] ca
# Depends : R (v4.2.1)
# Imports : jtheme (v0.0.2) [https://github.com/jeremieboudreault/jtheme]
# License : CC BY-NC-ND 4.0



# Library ----------------------------------------------------------------------


library(data.table)
library(jtheme)
library(tree)


# Imports ----------------------------------------------------------------------


x <- data.table::fread("rmd/data/donnees_peche_classification.csv")


# Plot raw data ----------------------------------------------------------------


# Plot.
ggplot(data = x, aes(x = Debit, y = Temperature)) +
    geom_point(aes(col = Peche, fill = Peche), alpha = 0.1, pch = 21) +
    scale_color_manual(values = c(colors$red, colors$blue)) +
    scale_fill_manual(values = c(colors$red, colors$blue)) +
    labs(x = "Débit (m3/s)", y = "Température de l'air (ºC)", fill = "", col = "") +
    ggtitle("Valeurs seuils pour l'ouverture de la pêche") +
    jtheme::jtheme(legend_alpha = 1, borders = "all", legend_pos = "bottomright")

# Save.
jtheme::save_ggplot("plots/dt/fig_1_data_overview.png", size = "rectsmall")


# Find decisions boudaries -----------------------------------------------------


# Full model.
model_full <- tree::tree(
    formula = as.factor(Peche) ~ Debit + Temperature,
    data    = x,
    control = tree::tree.control(
        nobs   = nrow(data),
        mindev = 0
    )
)

# Prune to 3 leaves.
model_small <- tree::prune.tree(model_full, best = 3)

# Plot and save small model.
jtheme::save_plot(
    file = "plots/dt/fig_2_tree_3_leaves.png",
    size = "rectsmall",
    pl_expr = {
        par(mar = c(1.5, 1, 3, 1.5))
        plot(model_small)
        text(model_small, pretty = 1L)
        title("Arbre de décision avec 3 feuilles")
    }
)


# Plot decision boundaries -----------------------------------------------------


# Boundaries.
temp_cut <- 18.8
flow_cut <- 129

# Plot.
ggplot(data = x, aes(x = Debit, y = Temperature)) +
    geom_point(aes(col = Peche, fill = Peche), alpha = 0.1, pch = 21) +
    scale_color_manual(values = c(colors$red, colors$blue)) +
    scale_fill_manual(values = c(colors$red, colors$blue)) +
    geom_hline(yintercept = temp_cut, lwd = 0.2) +
    geom_segment(x = flow_cut, xend = flow_cut, y = Inf, yend = temp_cut, lwd = 0.2) +
    labs(x = "Débit (m3/s)", y = "Température de l'air (ºC)", fill = "", col = "") +
    ggtitle("Valeurs seuils pour l'ouverture de la pêche") +
    jtheme::jtheme(legend_alpha = 1, borders = "all", legend_pos = "bottomright")

# Save.
jtheme::save_ggplot("plots/dt/fig_3_tree_3_leaves_regions.png", size = "rectsmall")


# Predictions ------------------------------------------------------------------


# Extract the optimal model.
model_optimal <- tree::prune.tree(model_full, best = 7)

# Generate plots for 50% and 95%.
plist <- lapply(X = c(0.50, 0.05), FUN = function(w) {

    # Predict
    x$Prediction <- c("Fermée", "Ouverte")[(predict(model_optimal, newdata = x)[, 2] > 1 - w) + 1]

    # Plot.
    return(ggplot(data = x, aes(x = Debit, y = Temperature)) +
    geom_point(aes(col = Prediction, fill = Prediction), alpha = 0.1, pch = 21) +
    scale_color_manual(values = c(colors$red, colors$blue)) +
    scale_fill_manual(values = c(colors$red, colors$blue)) +
    #geom_hline(yintercept = temp_cut, lwd = 0.2) +
    #geom_segment(x = flow_cut, xend = flow_cut, y = Inf, yend = temp_cut, lwd = 0.15) +
    labs(x = NULL, y = NULL, fill = "", col = "") +
    ggtitle(paste0("Seuil ", w * 100, "%")) +
    jtheme::jtheme(title_size = 12L, title_face = "plain", legend_alpha = 1, borders = "all", legend_pos = "bottomright")
    )

})

# Combine two plots.
jarrange(
    plist      = plist,
    title      = "Prédiction de l'ouverture de la pêche",
    bottom     = "Débit (m3/s)",
    left       = "Température de l'air (ºC)",
    legend_pos = "right"

)

# Save plot.
save_ggplot("plots/dt/fig_4_predictions.png", w = 8, h = 4)
