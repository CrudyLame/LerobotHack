
import numpy as np

try:
    from lerobot.teleoperators.so_leader import SO101LeaderConfig, SO101Leader
except Exception as exc:  # pragma: no cover
    SO101LeaderConfig = None
    SO101Leader = None
    _IMPORT_ERROR = exc
else:
    _IMPORT_ERROR = None


class SO101MasterArmController:
    """Мост между реальной мастер-рукой SO-101 и симуляцией MuJoCo.

    Возвращает action в порядке суставов, ожидаемом SimpleEnv(action_type='joint_angle'):
    [shoulder_pan, shoulder_lift, elbow_flex, wrist_flex, wrist_roll, gripper]
    """

    JOINT_ORDER = [
        "shoulder_pan",
        "shoulder_lift",
        "elbow_flex",
        "wrist_flex",
        "wrist_roll",
        "gripper",
    ]

    def __init__(
        self,
        port: str,
        leader_id: str = "leader",
        use_degrees: bool = False,
        motion_threshold: float = 0.03,
        sign_map: dict | None = None,
        offset_map: dict | None = None,
    ):
        if _IMPORT_ERROR is not None:
            raise ImportError(
                "Не удалось импортировать SO101Leader из LeRobot. "
                "Убедись, что окружение установлено с поддержкой SO-101."
            ) from _IMPORT_ERROR

        self.port = port
        self.leader_id = leader_id
        self.use_degrees = use_degrees
        self.motion_threshold = motion_threshold
        self.sign_map = sign_map or {name: 1.0 for name in self.JOINT_ORDER}
        self.offset_map = offset_map or {name: 0.0 for name in self.JOINT_ORDER}
        self.device = None
        self.reference_action = None

    def connect(self):
        cfg = SO101LeaderConfig(
            port=self.port,
            id=self.leader_id,
            use_degrees=self.use_degrees,
        )
        self.device = SO101Leader(cfg)
        self.device.connect()
        return self

    def disconnect(self):
        if self.device is not None:
            try:
                self.device.disconnect()
            except Exception:
                pass
            self.device = None

    def reset_reference(self):
        self.reference_action = None

    def _extract_joint_value(self, raw_action: dict, joint_name: str) -> float:
        if joint_name in raw_action:
            return float(raw_action[joint_name])
        key = f"{joint_name}.pos"
        if key in raw_action:
            return float(raw_action[key])
        raise KeyError(
            f"Сустав '{joint_name}' не найден в action leader. Доступные ключи: {list(raw_action.keys())}"
        )

    def _clip_action(self, action: np.ndarray) -> np.ndarray:
        q_min = np.array([
            -1.91986,
            -1.74533,
            -1.69,
            -1.65806,
            -2.74385,
            -0.17453,
        ], dtype=np.float32)
        q_max = np.array([
            1.91986,
            1.74533,
            1.69,
            1.65806,
            2.84121,
            1.74533,
        ], dtype=np.float32)
        return np.clip(action.astype(np.float32), q_min, q_max)

    def get_action(self) -> np.ndarray:
        if self.device is None:
            raise RuntimeError("Мастер-рука не подключена. Сначала вызови connect().")

        raw_action = self.device.get_action()
        out = []
        for joint_name in self.JOINT_ORDER:
            value = self._extract_joint_value(raw_action, joint_name)
            value = self.sign_map[joint_name] * value + self.offset_map[joint_name]
            out.append(value)

        action = self._clip_action(np.array(out, dtype=np.float32))
        if self.reference_action is None:
            self.reference_action = action.copy()
        return action

    def has_significant_motion(self, action: np.ndarray) -> bool:
        if self.reference_action is None:
            self.reference_action = action.copy()
            return False
        return float(np.linalg.norm(action - self.reference_action)) > self.motion_threshold
