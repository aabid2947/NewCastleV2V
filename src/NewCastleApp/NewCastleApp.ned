

package newcastlev2v.NewCastleApp;  // Package should match directory structure

// Import the base class
import org.car2x.veins.modules.application.ieee80211p.DemoBaseApplLayer;

simple NewCastleApp extends DemoBaseApplLayer
{
    parameters:
        @class(newcastlev2v::NewCastleApp);  // Namespace should match C++ file

        double broadcastInterval @unit(s) = default(1s);
        double periodicLoggingInterval @unit(s) = default(0.1s);
        double safetyDistanceThreshold @unit(m) = default(10m);

        // headerLength is inherited from DemoBaseApplLayer
        // int headerLength @unit(bit) = default(88bit);

        bool logVehicleData = default(true);
        string logFileName = default("v2v_log.txt");

        @display("i=block/app2");

    // Gates are inherited from DemoBaseApplLayer
}