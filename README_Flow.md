# System Flow and Working

---

## Overview

This document explains the step-by-step working flow of the system, including movement, sensing, decision-making, and pesticide spraying. The focus is on clarity and practical understanding of how the system operates in real farming conditions.

---

## Overall System Flow

The system operates as a continuous cycle while moving through crop rows. Each plant is observed, evaluated, and treated only if required. This ensures efficient use of pesticides and minimizes unnecessary chemical exposure.

---

## Step-by-Step Working Flow

1. **System Start-Up**  
   The system is powered using a rechargeable battery. Once powered on, all modules initialize, including motors, camera, sensors, and control units.

2. **Movement Through Crop Rows**  
   The mobile platform moves forward along predefined paths between crop rows. Speed and direction are controlled to ensure stable movement and accurate observation.

3. **Plant Observation**  
   As the system moves, the camera captures images of plant leaves. These images are used to assess plant condition during operation.

4. **Condition Evaluation**  
   The captured images are processed to determine whether a plant requires treatment. If the plant appears healthy, the system continues moving without taking action.

5. **Decision Making**  
   If signs of infection are identified, the system decides whether pesticide spraying is required. The decision is based on observed plant condition.

6. **Selective Spraying**  
   When treatment is required, the spraying mechanism is activated. A relay switches on the pumping motor, allowing pesticide to be sprayed through the nozzles. Only the affected plant area is treated.

7. **Soil Condition Monitoring**  
   Soil sensors collect required data related to soil condition during operation. This data is recorded for monitoring and future reference.

8. **Data Reporting**  
   Information such as crop condition, soil readings, and system activity is sent to the monitoring interface. This allows farmers to stay informed without being present in the field.

9. **Repeat Cycle**  
   After completing one observation and action cycle, the system moves forward to the next plant and repeats the process.

---

## Control Flow Summary

- Start system  
- Move along crop rows  
- Capture plant image  
- Evaluate plant condition  
- Decide whether treatment is required  
- Activate spraying if needed  
- Monitor soil condition  
- Report data  
- Continue to next plant  

---

## Flow Characteristics

- Operates in a continuous loop  
- Spraying occurs only when required  
- No action taken for healthy plants  
- Designed to minimize chemical usage  
- Supports real-time monitoring  

---

## Future Enhancements

The flow is designed to support future improvements such as advanced monitoring, extended data storage, and improved decision logic. These enhancements are planned for the next development phase and are documented in `README_Round2.md`.

---

## Related Documents

- `docs/system_architecture.md`  
- `docs/background_and_prior_art.md`  
- `docs/novelty_and_objectives.md`  
- `README_Round2.md`

