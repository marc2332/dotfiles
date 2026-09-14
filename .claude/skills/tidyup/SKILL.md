---
name: tidy-up
description: Tidy up the code.
---

- Remove reasoning, justification and thinking from your comments. 
- Cap the comments to max 2 lines. 
- Don't use em dashes or semicolons in comments.
- Inline functions that are trivial and only used in max 2 places.
- Add documentation comments where needed.
- Dont leave anything undone unless told so.
- Always try to have methods attached to their respective data types (classes, structs, enums) rather than be random functions taking its data type as first argument.
- Analyze the code to see if you can reuse existing types rather than creating new ones.
- Leave empty lines between different regions in the code logic to make it more readable.
- Looks for unnecessary and trivial clones or copies of values.
- Dont add comments to types or functions whose name already explains what it does.
- Write a table of your changes, be direct, concise, compact and use plain words.
