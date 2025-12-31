# System Architecture

---

### `Overview`

The system is designed as a modular and practical architecture that combines a mobile hardware unit with embedded control, sensing, and user monitoring components. Each module performs a clearly defined role, allowing the system to operate efficiently in real farm environments while remaining easy to understand, maintain, and extend in future stages.

The architecture follows a layered approach, starting from physical components in the field and extending up to farmer-facing monitoring interfaces.

---

### `Hardware Layer`

The hardware layer consists of a mobile robotic platform designed for row-based farming. A four-wheel chassis driven by DC motors enables controlled movement along crop paths. A pesticide storage tank, pumping motors, and sprinklers are mounted on the platform to enable selective spraying.

A camera module is positioned to capture clear images of plant leaves during movement. Soil sensors are placed close to the ground to measure soil-related parameters such as moisture and condition. Power is supplied through a battery system with voltage regulation to ensure stable operation of all components.

---

### `Control and Processing Layer`

At the core of the system is an onboard processing unit responsible for coordinating all operations. This unit handles image input from the camera, decision-making logic, and communication with peripheral devices.

A microcontroller is used to manage low-level tasks such as motor control, relay switching for the pump, and sensor data collection. Communication between the processing unit and the microcontroller ensures synchronized movement, sensing, and spraying actions.

---

### `Spraying and Actuation Layer`

The spraying mechanism operates based on control signals received from the processing unit. When treatment is required, a relay activates the pumping motor, allowing pesticide to flow from the tank to the sprinklers. If no action is required, the spraying system remains inactive, preventing unnecessary chemical usage.

This layer ensures that pesticide application is controlled, localized, and efficient.

---

### `Monitoring and Communication Layer`

The system includes a communication module that transfers operational data to a farmer-facing interface. Information such as crop condition status, soil readings, and system activity is transmitted for monitoring purposes.

This layer enables farmers to stay informed about field conditions without being physically present, supporting better planning and right-time corrective action.

---

### `User Interface Layer`

The user interface layer presents system data in a simple and understandable format. Farmers can view crop health summaries, soil condition updates, and system status through a mobile or dashboard-based interface.

This layer focuses on usability and clarity, ensuring that farmers with limited technical background can easily understand and benefit from the system.

---

### `System Workflow Summary`

1. The robot moves along crop rows.
2. The camera captures plant images while sensors collect soil data.
3. The processing unit evaluates inputs and determines required action.
4. If treatment is needed, the spraying mechanism is activated.
5. Operational and field data are sent to the monitoring interface.
6. The system continues operation for the next set of plants.

---

### `Design Considerations`

The system architecture prioritizes simplicity, modularity, and affordability. Each layer is designed to function independently while integrating seamlessly with others. This approach allows future enhancements, such as expanded monitoring features or improved control logic, without requiring a complete redesign.

Overall, the architecture supports precise operation, reduced chemical usage, and improved farmer awareness while remaining suitable for real-world agricultural conditions.


