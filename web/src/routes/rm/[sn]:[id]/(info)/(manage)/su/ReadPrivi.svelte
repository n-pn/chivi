<!-- <script lang="ts">
  import { api_call } from '$lib/api_call'

  export let can_conf = false
  export let conf_url: string

  export let ustem: CV.Upstem

  const read_privis = [
    [0, 'Cần đăng nhập'],
    [1, 'Quyền hạn 1'],
    [2, 'Quyền hạn 2'],
    [3, 'Quyền hạn 3'],
    [-1, 'Không hạn chế'],
  ]

  const read_privi_descs = {
    0: 'Không hạn chế đọc 1/3 số chương đầu, cần đăng nhập để đọc 2/3 số chương tiếp theo',
    1: 'Cần đăng nhập để đọc 1/3 số chương đầu, cần quyền hạn 1+ để đọc 2/3 số chương tiếp theo',
    2: 'Cần quyền hạn 1+ để đọc 1/3 số chương đầu, cần quyền hạn 2+ để đọc 2/3 số chương tiếp theo',
    3: 'Cần quyền hạn 2+ để đọc 1/3 số chương đầu, cần quyền hạn 3+ để đọc 2/3 số chương tiếp theo',
    '-1': 'Tất cả mọi người đều đọc được nội dung các chương',
  }

  let error = ''

  const update_read_privi = async () => {
    try {
      const body = { read_privi: seed_data.read_privi }
      ustem = await api_call(conf_url, body, 'PATCH')
    } catch (ex) {
      error = ex.body.message
    }
  }
</script>

<div class="options">
  {#each read_privis as [value, label]}
    <label class="radio">
      <input
        type="radio"
        {value}
        bind:group={seed_data.read_privi}
        disabled={+value > _privi} />
      <span> {label}</span>
    </label>
  {/each}
</div>

<div class="desc">{read_privi_descs[seed_data.read_privi]}</div>

{#if error}<div class="error">{error}</div>{/if}

<footer class="action">
  <button
    class="m-btn _primary _fill"
    disabled={!can_conf}
    on:click={update_read_privi}>
    <span>Lưu thay đổi</span>
  </button>
</footer>

<style lang="scss">
  .options {
    display: flex;
    flex-wrap: wrap;
    margin-top: 0.75rem;
  }

  .radio {
    cursor: pointer;
    line-height: 2rem;
    margin-right: 0.5rem;
    input {
      margin-right: 0.25rem;
    }
  }

  .error {
    @include fgcolor(harmful, 5);
  }

  .desc {
    font-style: italic;
    @include fgcolor(tert);
    margin-bottom: 1rem;
  }
</style> -->
