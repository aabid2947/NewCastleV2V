# NewCastleV2V Project: Setting up a Custom Map

This guide explains how to use your own road network map data with the NewCastleV2V simulation project. It covers obtaining map data, converting it for SUMO, generating vehicle routes, and configuring the OMNeT++ simulation.

## Prerequisites

Before you begin, ensure you have the following installed and set up:

-   **OMNeT++:** A working installation of OMNeT++.
-   **Veins:** Veins framework integrated with your OMNeT++ installation.
-   **SUMO:** SUMO (Simulation of Urban MObility) installed and configured, including its command-line tools (`netconvert`, `randomTrips.py`, etc.) and Python tools. Ensure the SUMO `bin` directory is in your system's PATH, or you know the absolute paths to the tools.
-   **NewCastleV2V Project:** You have cloned or have access to the NewCastleV2V project source code.

## Step 1: Obtaining Road Network Map Data

You can obtain road network data in OpenStreetMap (.osm) format for your desired area.

1.  Go to the [OpenStreetMap website](https://www.openstreetmap.org/).
2.  Navigate to the area you want to simulate.
3.  Click the **Export** button at the top of the page.
4.  You can manually select a smaller area if the default export area is too large (OpenStreetMap has export limits). Click **Manually select a different area** and drag the bounding box.
5.  Click the **Export** button in the left sidebar. This will download an `.osm` file (e.g., `map.osm`).

Place the downloaded `.osm` file inside your `NewCastleV2V/simulations/NewCastleSimulation` directory (or a dedicated `maps` subdirectory within it). Let's assume the file is named `your_map.osm`.

## Step 2: Converting the Map to SUMO Network Format

SUMO requires the road network in its own format (`.net.xml`). You will use the `netconvert` tool included with SUMO to perform this conversion.

1.  Open a terminal or command prompt.
2.  Navigate to the directory where you saved your `.osm` file (e.g., `NewCastleV2V/simulations/NewCastleSimulation`).
3.  Run the `netconvert` command. A basic command looks like this:

    ```bash
    netconvert --osm-files your_map.osm -o your_map.net.xml
    ```

    * `--osm-files your_map.osm`: Specifies the input OpenStreetMap file.
    * `-o your_map.net.xml`: Specifies the output SUMO network file name.

    **Important Considerations:**

    * **SUMO Type Files:** `netconvert` often requires SUMO's type mapping files to correctly interpret OpenStreetMap road types. These are usually located in the `SUMO_HOME/data/typemaps` directory. You might need to include them in the command:

        ```bash
        netconvert --osm-files your_map.osm --osm.railway.pt off --osm.tram.pt off --osm.bus.pt off --osm.pt.guess --output-file your_map.net.xml --osm.typemap.file <SUMO_HOME>/data/typemaps/osmNetconvert.typ.xml
        ```
        Replace `<SUMO_HOME>` with the actual path to your SUMO installation directory.

    * **Projection:** If your simulation requires accurate geographic positioning, you might need to specify a projection. Refer to the SUMO documentation for details on using the `--proj` option with `netconvert`.

    * **Errors/Warnings:** `netconvert` might report warnings or errors about the input data. Review these and adjust the `.osm` file or `netconvert` options if necessary.

Upon successful execution, this will generate a `your_map.net.xml` file in your current directory.

## Step 3: Generating Vehicle Routes

Next, you need to generate a set of vehicle routes (`.rou.xml`) that vehicles will follow within your SUMO network. The `randomTrips.py` tool (part of SUMO's tools) is commonly used for this.

1.  Open a terminal or command prompt.
2.  Navigate to the directory containing your `your_map.net.xml` file (e.g., `NewCastleV2V/simulations/NewCastleSimulation`).
3.  Run the `randomTrips.py` script. A basic command is:

    ```bash
    python <SUMO_HOME>/tools/randomTrips.py -n your_map.net.xml -r your_routes.rou.xml -e 100 -p 1
    ```

    * `python <SUMO_HOME>/tools/randomTrips.py`: Executes the script using your Python interpreter. Replace `<SUMO_HOME>` with your SUMO installation path.
    * `-n your_map.net.xml`: Specifies the input network file.
    * `-r your_routes.rou.xml`: Specifies the output routes file name.
    * `-e 100`: Generates trips for the first 100 seconds of the simulation. Adjust as needed.
    * `-p 1`: Inserts one vehicle per second. Adjust the vehicle density as needed.

    **Important Considerations:**

    * **SUMO Tools Path:** Ensure the path to `randomTrips.py` is correct for your SUMO installation.
    * **Trip Generation Options:** `randomTrips.py` has many options to control the number of vehicles, departure times, origins, destinations, etc. Refer to the SUMO documentation for `randomTrips.py` for more advanced usage.
    * **Trip Validation:** Sometimes generated trips might not be routable on the network. `randomTrips.py` usually reports this.

This will generate a `your_routes.rou.xml` file.

## Step 4: Integrating Map and Routes into the OMNeT++ Project

Now you need to tell your Veins-based OMNeT++ simulation to use the network and routes files you just created.

1.  **Place Files:** Ensure `your_map.net.xml` and `your_routes.rou.xml` are located within your simulation's directory, typically `NewCastleV2V/simulations/NewCastleSimulation`.
2.  **Update `NewCastle.launchd.xml`:**
    * Open the `NewCastle.launchd.xml` file in your `NewCastleV2V/simulations/NewCastleSimulation` directory using a text editor or the OMNeT++ IDE.
    * Find the `<basedir>` tag and ensure it points to the absolute path of your `NewCastleV2V/simulations/NewCastleSimulation` directory.

        ```xml
        <launch>
            <basedir>/absolute/path/to/your/NewCastleV2V/simulations/NewCastleSimulation</basedir>
            ...
        </launch>
        ```
        Use forward slashes (`/`) for paths even on Windows.

    * Find the `<copy>` tags within the `<launch>` section. These tags tell `veins_launchd` which files to copy to the temporary SUMO working directory. Update or add `<copy>` tags to include your new network and routes files:

        ```xml
        <launch>
            <basedir>/absolute/path/to/your/NewCastleV2V/simulations/NewCastleSimulation</basedir>
            <copy file="your_map.net.xml"/>
            <copy file="your_routes.rou.xml"/>
            <copy file="your_simulation.sumocfg"/>
            ...
        </launch>
        ```
        Make sure the filenames here match the files you created.

    * **Update `.sumocfg` (if you have one):** If your simulation uses a main SUMO configuration file (`.sumocfg`), open it. Ensure that the `<net-file>` and `<route-files>` tags within the `<input>` section point to the names of your new files (`your_map.net.xml` and `your_routes.rou.xml`).

        ```xml
        <configuration>
            <input>
                <net-file value="your_map.net.xml"/>
                <route-files value="your_routes.rou.xml"/>
                <additional-files value="your_additional.add.xml"/>
            </input>
            ...
        </configuration>
        ```
        Ensure this `.sumocfg` file is also included in the `<copy>` tags of `NewCastle.launchd.xml`.

3.  **Update `omnetpp.ini`:**
    * Open your `omnetpp.ini` file (`NewCastleV2V/simulations/NewCastleSimulation/omnetpp.ini`).
    * Ensure the `*.manager.launchConfig` parameter points to your `NewCastle.launchd.xml` file.

        ```ini
        *.manager.launchConfig = xmldoc("NewCastle.launchd.xml")
        ```

    * Verify other parameters like `sim-time-limit` are appropriate for the duration of your generated routes.

## Step 5: Running the Simulation

Now you are ready to run the simulation with your custom map and routes.

1.  **Start the SUMO Launch Daemon (`veins_launchd`):**
    * Open a terminal or command prompt.
    * Navigate to the `bin` directory of your Veins installation.
    * Run `veins_launchd`, pointing it to your updated `NewCastle.launchd.xml` file:

        ```bash
        ./veins_launchd -vv -c /absolute/path/to/your/NewCastleV2V/simulations/NewCastleSimulation/NewCastle.launchd.xml
        ```
        Replace `/absolute/path/to/your/...` with the actual absolute path to your XML file.
    * **Keep this terminal window open and `veins_launchd` running.**

2.  **Run the OMNeT++ Simulation:**
    * Open the OMNeT++ IDE.
    * Go to **Run** -> **Run Configurations...** (or Debug Configurations...).
    * Select your simulation configuration for the NewCastleV2V project.
    * Click **Run** (or Debug).

The OMNeT++ simulation should now connect to the running `veins_launchd` daemon, which will use your specified `NewCastle.launchd.xml` to launch SUMO with your custom map and routes. You should see vehicles moving on your map in the SUMO-GUI (if enabled) and the simulation progressing in OMNeT++'s Qtenv or Cmdenv.

Remember to stop the `veins_launchd` process in the terminal after your simulation run is complete.
