    DISNEY - TOKENOMICS

    This is an example how to generate tokens to enjoy attractions and other services
    like food based on udemy course

    0. We use ERC20.sol to call token function
    1.1 We define a constructor
    1.2 We define an struct for customer variable
    1.3 We create a mapping to relate and address with customer data

    2. Tokens 
        2.1 We define token price
        2.2 We define a function to buy a token
            2.2.1 We determinate token price
            2.2.2 We use require to assure customer have enought tokens
            2.2.3 We use transfer function
        2.3 We create a function that allow increase tokens only by constructor

    3. DISNEY
        3.1 We create functions to create new attractions and remove
        3.2 Enjoyattraction function
        3.3 Return tokens
        3.4 We add new food service based on tokens
