<article class="m-article">
  <h1>Inputs</h1>

  <h2>Text fields</h2>

  <div class="u-flow">
    <div class="u-flex">
      <div class="m-input _small">
        <input type="text" name="#t1" />
        <label for="t1">Text 1</label>
      </div>

      <button class="m-button _small">Submit</button>
    </div>

    <div class="u-flex">
      <div class="m-input">
        <input type="text" name="#t2" />
        <label for="t2">Text 2</label>
      </div>

      <button class="m-button _fill _primary">Submit</button>
    </div>

    <div class="u-flex">
      <div class="m-input _large">
        <input type="text" name="#t3" />
        <label for="t3">Text 3</label>
      </div>

      <button class="m-button _large _line _harmful">Submit</button>
    </div>

    <div class="m-input">
      <textarea name="" id="input" cols="30" rows="10" />
    </div>
  </div>
</article>

<style lang="scss">
  .u-flex {
    @include flex;
  }

  .u-flow {
    > * + * {
      margin-top: 1rem;
    }
  }
</style>
