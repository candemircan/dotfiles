  ---
  description: Update workout templates with latest data from daily notes
  ---

  ## Context

  - Daily notes: !`ls Daily/`
  - Workout templates: !`ls Templates/Workout*`

  ## Your task

  1. Read the most recent daily notes that contain workout data (look for `### Workout:` headers)
  2. For each workout found, read the corresponding template in the Templates folder
  3. Update the template's table with the latest sets/reps/weights from the daily note
  4. If the daily note has messy/unstructured workout data below the table, organize it into the table first, then update the template
  5. Report what you updated

