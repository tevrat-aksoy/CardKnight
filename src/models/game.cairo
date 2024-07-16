use starknet::ContractAddress;
use card_knight::config::map::{MAP_RANGE};
use card_knight::models::player::{Player, IPlayer, Hero};
use card_knight::models::card::{Card, ICardTrait,};
use dojo::world::{IWorld, IWorldDispatcher, IWorldDispatcherTrait};

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Game {
    #[key]
    game_id: u32,
    #[key]
    player: ContractAddress,
    highest_score: u64,
    game_state: GameState
}

#[derive(Serde, Drop, Copy, PartialEq, Introspect)]
enum GameState {
    None,
    Playing,
    Win,
    Lose,
    WaitingForLevelUpOption
}

#[derive(Serde, Drop, Copy, PartialEq, Introspect)]
enum Direction {
    Up,
    Down,
    Left,
    Right,
}

#[derive(Serde, Drop, Copy, PartialEq, Introspect)]
enum TagType {
    None,
    Growth,
    NoMagic,
    Revenge,
    NoHope,
    Silent
}


fn apply_tag_effects(world: IWorldDispatcher, player: Player,) {
    let mut x: u32 = 0;
    let mut y: u32 = 0;
    while x <= MAP_RANGE {
        while y <= MAP_RANGE {
            let mut card = get!(world, (player.game_id, x, y), (Card));

            match card.tag {
                TagType::None => {},
                TagType::Growth => {
                    card.apply_growth_tag();
                    set!(world, (card));
                },
                TagType::NoMagic => {},
                TagType::Revenge => {
                    card.apply_revenge_tag();
                    set!(world, (card));
                },
                TagType::NoHope => {},
                TagType::Silent => {},
            };

            y = y + 1;
        };
        x = x + 1;
    };
}


fn is_silent(world: IWorldDispatcher, player: Player,) -> bool {
    let mut x: u32 = 0;
    let mut y: u32 = 0;
    let mut any_silent = false;
    while x <= MAP_RANGE {
        while y <= MAP_RANGE {
            let mut card = get!(world, (player.game_id, x, y), (Card));
            match card.tag {
                TagType::Silent => { any_silent = true },
                _ => {},
            };

            y = y + 1;
        };
        x = x + 1;
    };
    any_silent
}
