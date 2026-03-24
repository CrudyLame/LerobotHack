from __future__ import annotations

from .config import default_config
from .dataset import create_dataloader, load_dataset, save_stats_json
from .env_runner import close_env, create_env, replay_episode


def main() -> None:
    config = default_config()
    dataset = load_dataset(config)
    dataloader, episode_sampler = create_dataloader(dataset, config.episode_index)
    env = create_env(config)

    try:
        replay_episode(config, env, dataloader, episode_sampler)
    finally:
        close_env(env)

    if config.save_stats:
        save_stats_json(dataset)


if __name__ == "__main__":
    main()
