import supervision as sv
import numpy as np
from ultralytics import YOLO

VIDEO_PATH = "C:\\Users\\mouima\\Documents\\projet-ia\\vid_test.mp4"

model = YOLO("C:\\Users\\mouima\\Documents\\projet-ia\\runs\\segment\\best.pt")

video_info = sv.VideoInfo.from_video_path(VIDEO_PATH)
"""
def process_frame(frame: np.ndarray, _) -> np.ndarray:
    results = model(frame, imgsz=640)[0]
    
    detections = sv.Detections.from_yolov8(results)

    box_annotator = sv.BoxAnnotator(thickness=4, text_thickness=4, text_scale=2)

    labels = [f"{model.names[class_id]} {confidence:0.2f}" for _, _, confidence, class_id, _ in detections]
    frame = box_annotator.annotate(scene=frame, detections=detections, labels=labels)

    return frame
"""
def process_frame(frame, model, box_annotator):
    result = model(frame, agnostic_nms=True)[0]
    detections = sv.Detections.from_yolov8(result)
    labels = [
        f"{model.model.names[class_id]} {confidence:0.2f}"
        for _, confidence, class_id, _
        in detections
    ]
    annotated_frame = box_annotator.annotate(
        scene=frame,
        detections=detections,
        labels=labels
    )
    return annotated_frame

sv.process_video(source_path=VIDEO_PATH, target_path=f"result.mp4", callback=process_frame)


