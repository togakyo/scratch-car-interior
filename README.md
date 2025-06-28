# Scratch Car

This is a simple, interactive web-based project that leverages the Blockly library to provide a visual programming environment. Users can drag and drop blocks to create programs that control a virtual car's functionalities, such as turning its lights on/off and playing/stopping its horn. It serves as an educational tool to introduce basic programming concepts through a fun and engaging interface.

## How to Use

1.  **Start a web server:**
    You need to run a simple web server from the project's root directory. If you have Python installed, you can use the following command:
    ```bash
    python3 -m http.server
    ```
    If you don't have Python, you can use any other simple web server.

2.  **Open the project in your browser:**
    Once the server is running, open your web browser and go to the following address:
    [http://localhost:8000](http://localhost:8000)

    You should see a virtual car and a Blockly editor. You can drag and drop blocks to create a program to control the car's lights and horn.

## How to Debug

1.  **Open the developer console:**
    In your web browser, open the developer console. You can usually do this by right-clicking on the page and selecting "Inspect" or by pressing `F12`.

2.  **Check for errors:**
    Any errors in the JavaScript code will be displayed in the console.

3.  **Check for log messages:**
    The `script.js` file contains `console.log` statements that print messages to the console when the car's lights and horn are activated. You can use these messages to see what the code is doing.

## Recent Changes

-   **Fixed Blockly Generator Output:** Corrected an issue where the JavaScript generator functions for the `car_light` and `car_horn` blocks were producing invalid code due to an unnecessary backslash in the return statement. This resolves the `JavaScript generator does not know how to generate code for block type "car_light"` error.
-   **Updated `index.html`:** Modified script loading to include a version parameter and defer loading, and changed the "実行" button text to "Execute" for clarity.
