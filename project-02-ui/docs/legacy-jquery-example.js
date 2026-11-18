/**
 * Legacy jQuery tabs — maintenance review points
 *
 * Existing tab handlers may conflict when global selectors and unscoped
 * click events affect unrelated components. Review these areas when updating
 * an existing site:
 *
 * - Restrict selectors and state updates to the relevant component.
 * - Use namespaced events to avoid removing handlers owned by other features.
 * - Synchronize ARIA attributes, focused tab, and visible panel.
 * - Separate URL state updates from default anchor scrolling.
 * - Preserve access to the content if JavaScript fails to initialize.
 *
 * The working implementation for this project is in ../js/tabs.js.
 */
