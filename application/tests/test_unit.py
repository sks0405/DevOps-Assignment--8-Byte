def test_home_response():
    from app import home

    assert home() == "DevOps Assignment application is running!"


def test_health_response():
    from app import health

    response, status_code = health()

    assert response["status"] == "healthy"
    assert status_code == 200
