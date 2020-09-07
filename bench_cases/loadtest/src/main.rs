use goose::prelude::*;
use rand::Rng;
use rand::seq::SliceRandom;
use serde_json::json;

async fn cards_create(user: &GooseUser) -> GooseTaskResult {
    let colors_vec = vec!["red", "green", "blue"];
    let users_rng: u8 = rand::thread_rng().gen_range(1, 6);
    let count_rng: i32 = rand::thread_rng().gen_range(20, 400);
    let color_val = &colors_vec.choose(&mut rand::thread_rng());
    let request_url = format!("/users/{}/cards/buy", users_rng);
    let request_builder = user.goose_post(&request_url).await?;
    let json_params = json!({
        "color": format!("{}", color_val.unwrap()),
        "count": format!("{}", &count_rng.to_string()),
    });
    let _goose = user.goose_send(request_builder.json(&json_params), None).await?;

    Ok(())
}

async fn cards_use(user: &GooseUser) -> GooseTaskResult {

    let colors_vec = vec!["red", "green", "blue"];
    let users_rng: u8 = rand::thread_rng().gen_range(1, 6);
    let color_val = &colors_vec.choose(&mut rand::thread_rng());

    let request_url = format!("/users/{}/cards/use", users_rng);
    let request_builder = user.goose_post(&request_url).await?;

    let json_params = json!({
        "color": format!("{}", color_val.unwrap()),
    });
    let _goose = user.goose_send(request_builder.json(&json_params), None).await?;

    Ok(())
}

fn main() -> Result<(), GooseError> {
    GooseAttack::initialize()?
    .register_taskset(
        taskset!("CartUser")
        .register_task(task!(cards_create))
        .register_task(task!(cards_use))
    )
    .execute()?
    .print();

    Ok(())
}
